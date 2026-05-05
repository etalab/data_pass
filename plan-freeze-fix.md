# Plan : Résoudre les freezes système (OOM)

## Diagnostic

Le système freeze régulièrement à cause d'un **manque de mémoire** (OOM).
Machine : 16 Go de RAM, 4 Go de swap.

Événements de pression mémoire constatés dans les logs :
- 17 mars ~9h44
- 19 mars ~10h05
- 20 mars ~9h52 → freeze complet → REISUB

Les logs montrent clairement :
- `systemd-journald: Under memory pressure, flushing caches` (en boucle)
- `libinput error: scheduled expiry is in the past (-19062ms), your system is too slow`
- `OOM killer disabled` (par un cgroup Docker) → le kernel ne peut pas tuer de processus pour libérer la mémoire → thrashing → freeze total

### Consommateurs de mémoire (juste après reboot = charge minimale)

| Processus | RAM |
|---|---|
| 7× copilot.vim language-server (node) | ~1.5 Go |
| Mattermost (Electron, 15 processus) | ~800 Mo |
| Claude CLI | ~420 Mo |
| gnome-shell | ~420 Mo |
| gnome-software | ~200 Mo |
| konsole | ~200 Mo |
| **Total RSS** | **~7.7 Go** |

Avant le freeze, il y avait en plus : Chromium, Brave, Docker (postgres,
redis, chrome headless), et probablement des processus Rails/Ruby.

---

## Étape 1 : Installer earlyoom (priorité critique)

Empêche le freeze en tuant le processus le plus gourmand AVANT que le
système devienne inutilisable.

```bash
sudo apt install earlyoom
sudo systemctl enable --now earlyoom
```

Vérifier que c'est actif :
```bash
systemctl status earlyoom
```

Configuration par défaut : intervient quand RAM + swap < 10%. C'est un bon
défaut. Pour personnaliser :
```bash
sudo vim /etc/default/earlyoom
# Exemple : EARLYOOM_ARGS="-m 5 -s 5 --prefer '(chromium|chrome|brave)'"
# -m 5 = intervient à 5% de RAM libre
# --prefer = tue en priorité les navigateurs plutôt que l'IDE
sudo systemctl restart earlyoom
```

---

## Étape 2 : Augmenter le swap de 4 Go à 16 Go

Donne beaucoup plus de tampon avant d'atteindre l'OOM. 695 Go de libre sur
le disque, donc pas de souci d'espace.

```bash
sudo swapoff /swap.img
sudo fallocate -l 16G /swap.img
sudo chmod 600 /swap.img
sudo mkswap /swap.img
sudo swapon /swap.img
```

Vérifier :
```bash
free -h
# La ligne Échange doit afficher 16Gi
```

Le fichier `/etc/fstab` contient déjà la ligne pour `/swap.img`, donc il
sera activé au prochain redémarrage automatiquement.

---

## Étape 3 : Activer le SysRq (au cas où)

Les logs montrent `sysrq: This sysrq operation is disabled.` — certaines
touches SysRq étaient bloquées. Pour les activer toutes :

```bash
echo "kernel.sysrq = 1" | sudo tee /etc/sysctl.d/90-sysrq.conf
sudo sysctl -p /etc/sysctl.d/90-sysrq.conf
```

---

## Étape 4 : Copilot.vim — activer uniquement dans la session active

Actuellement 7 instances du language server Node.js tournent (~210 Mo
chacune). Le plugin est chargé immédiatement dans chaque session nvim.

### Solution : lazy-load + toggle sur FocusGained/FocusLost

Modifier `~/.config/nvim/init.lua`, remplacer la ligne 708 :

```lua
{ 'github/copilot.vim' },
```

par :

```lua
{
  'github/copilot.vim',
  cmd = { 'Copilot' },
  event = { 'FocusGained' },
  init = function()
    vim.g.copilot_enabled = false

    vim.api.nvim_create_autocmd('FocusGained', {
      group = vim.api.nvim_create_augroup('copilot-focus', { clear = true }),
      callback = function()
        vim.g.copilot_enabled = true
      end,
    })

    vim.api.nvim_create_autocmd('FocusLost', {
      group = vim.api.nvim_create_augroup('copilot-unfocus', { clear = true }),
      callback = function()
        vim.g.copilot_enabled = false
      end,
    })
  end,
},
```

Cela fait que :
- Copilot ne démarre qu'au premier focus (pas au lancement)
- Les suggestions sont désactivées dans les fenêtres sans focus
- **Limitation** : le processus Node.js reste en mémoire une fois démarré,
  mais il ne fera plus de travail en arrière-plan (pas de requêtes API, pas
  de calcul de suggestions). C'est un compromis acceptable.

Pour aller plus loin (optionnel) : tu peux ajouter un raccourci pour
toggle manuellement :

```lua
vim.keymap.set('n', '<leader>tc', function()
  vim.g.copilot_enabled = not vim.g.copilot_enabled
  print('Copilot ' .. (vim.g.copilot_enabled and 'enabled' or 'disabled'))
end, { desc = '[T]oggle [C]opilot' })
```

---

## Étape 5 : Nettoyer Docker

Aucun container Docker ne devrait tourner pour DataPass (développement
local sans Docker). Nettoyer les containers et images inutilisés :

```bash
docker stop $(docker ps -q) 2>/dev/null
docker system prune -a
```

Pour empêcher Docker de démarrer automatiquement au boot (économise de la
RAM en permanence) :

```bash
sudo systemctl disable docker.service
sudo systemctl disable containerd.service
```

Tu pourras toujours le démarrer manuellement si besoin :
```bash
sudo systemctl start docker
```

---

## Étape 6 : Arrêter gnome-software (optionnel, ~200 Mo)

`gnome-software` consommait 200 Mo et 13% CPU au démarrage. Si tu ne
l'utilises pas pour gérer les paquets graphiquement :

```bash
sudo apt remove gnome-software
# ou juste empêcher le démarrage auto :
mkdir -p ~/.config/autostart
cp /etc/xdg/autostart/org.gnome.Software.desktop ~/.config/autostart/
echo "Hidden=true" >> ~/.config/autostart/org.gnome.Software.desktop
```

---

## Résumé des gains estimés

| Action | RAM économisée |
|---|---|
| earlyoom | 0 (mais empêche le freeze) |
| Swap 16 Go | 0 (mais +12 Go de tampon) |
| Copilot focus-only | ~1 Go (5 instances inactives) |
| Désactiver Docker au boot | ~200-500 Mo |
| Supprimer gnome-software | ~200 Mo |
| **Total** | **~1.5-2 Go + protection OOM** |

Les étapes 1 et 2 sont les plus critiques : elles ne changent rien à ton
workflow mais empêchent le freeze. Les étapes 4 et 5 réduisent la pression
mémoire à la source.
