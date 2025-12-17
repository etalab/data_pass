# ProConnect Logout Implementation

## Summary

This document describes the implementation of ProConnect logout functionality using the built-in capabilities of the `omniauth-proconnect` gem (v0.5).

## Implementation Details

### 1. Logout Flow (`app/controllers/sessions_controller.rb`)

The logout implementation is simple - we redirect to `/auth/proconnect/logout` and let the gem handle everything:

```ruby
def destroy
  identity_federator = current_identity_federator

  # Clear local session
  sign_out

  # Redirect to identity provider logout
  # For ProConnect, the omniauth-proconnect gem handles the logout flow automatically
  redirect_to signout_url(identity_federator), allow_other_host: true
end

def signout_url(current_identity_federator)
  case current_identity_federator
  when 'mon_compte_pro'
    mon_compte_pro_signout_url
  else
    # ProConnect logout is handled by the omniauth-proconnect gem
    '/auth/proconnect/logout'
  end
end
```

### 2. How the omniauth-proconnect Gem Handles Logout

The gem automatically:
1. Detects requests to `/auth/proconnect/logout`
2. Retrieves the `id_token` from `session['omniauth.pc.id_token']` (stored during login)
3. Retrieves the `state` from `session['omniauth.state']`
4. Builds the ProConnect `end_session_endpoint` URL with proper parameters:
   - `id_token_hint`
   - `state`
   - `post_logout_redirect_uri` (from the OmniAuth configuration)
5. Redirects to ProConnect's logout endpoint
6. ProConnect terminates all sessions and redirects back to `post_logout_redirect_uri`

### 3. Routes (`config/routes.rb`)

Only one route is needed:

```ruby
get 'compte/deconnexion', to: 'sessions#destroy', as: :signout
```

### 4. View Updates (`app/views/layouts/header/_tools.html.erb`)

Disabled Turbo on the logout link to ensure proper redirect handling:

```erb
<a class="fr-link fr-icon-logout-box-r-fill" id="signout_button" 
   href="<%= signout_path %>" data-turbo="false">
  <%= t('.links.sign_out.title') %>
</a>
```

## Compliance with ProConnect Specification

The `omniauth-proconnect` gem handles all OIDC compliance requirements:

1. ✅ **Stores `id_token`** during authentication in `session['omniauth.pc.id_token']`
2. ✅ **Uses proper end_session endpoint**: `/api/v2/session/end`
3. ✅ **Includes required parameters**:
   - `id_token_hint`: Retrieved from session
   - `state`: CSRF protection token
   - `post_logout_redirect_uri`: From OmniAuth configuration
4. ✅ **Redirects in browser**: Ensures ProConnect and Identity Provider sessions are terminated
5. ✅ **Verifies state**: Handled by the gem
6. ✅ **Cleans up session data**: Gem manages session cleanup

## Testing

The implementation can be tested by:

1. Login with ProConnect
2. Click "Se déconnecter"
3. Verify in browser network tab:
   - Request to `/auth/proconnect/logout`
   - Redirect to ProConnect's `/api/v2/session/end` endpoint
   - Redirect back to `post_logout_redirect_uri` (configured root URL)

## Key Discoveries

### 1. Built-in Logout Support
The `omniauth-proconnect` gem (v0.5) has built-in logout functionality. When a request is made to `/auth/proconnect/logout`, the gem:
- Automatically retrieves the `id_token` from `session['omniauth.pc.id_token']`
- Builds the proper ProConnect `end_session_endpoint` URL
- Handles all OIDC logout parameters
- Redirects to ProConnect

**No custom implementation needed** - just redirect to `/auth/proconnect/logout` and the gem does the rest!

### 2. Post-Logout Redirect URI Registration

**IMPORTANT**: The `post_logout_redirect_uri` must be **exactly registered** in the ProConnect configuration panel.

Currently configured in `config/initializers/omniauth.rb`:
```ruby
post_logout_redirect_uri: URI(host).to_s,  # e.g., "http://localhost:3000" or "https://datapass.api.gouv.fr"
```

This URL must be registered in the ProConnect partner portal:
1. Go to https://partenaires.proconnect.gouv.fr/
2. Select your application
3. Add the post-logout redirect URI (e.g., `http://localhost:3000` for development, `https://datapass.api.gouv.fr` for production)

**Error if not registered**: 
```
code erreur: oidc-provider-rendered-error:invalid_request
message erreur: "post_logout_redirect_uri not registered"
```

**Note**: The gem uses the `post_logout_redirect_uri` configured in `config/initializers/omniauth.rb`. We use the root URL because:
- It simplifies the configuration (only one URL to register per environment)
- ProConnect returns the user to the home page after logout, which is the expected UX
- The gem handles all state verification automatically

