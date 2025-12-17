# ProConnect Logout Implementation

## Summary

This document describes the implementation of proper ProConnect logout functionality according to the official ProConnect OIDC specification.

## Implementation Details

### 1. Session Management (`app/controllers/concerns/authentication.rb`)

The `sign_in` method now accepts an optional `id_token` parameter that is stored in the session:

```ruby
def sign_in(user, identity_federator:, identity_provider_uid:, id_token: nil)
  session[:user_id] = {
    value: user.id,
    expires_at: 1.month.from_now,
    identity_federator:,
    identity_provider_uid:,
  }

  # Store id_token for ProConnect logout
  session[:id_token] = id_token if id_token.present?

  @current_user = user
end
```

### 2. Login Flow (`app/controllers/sessions_controller.rb`)

During ProConnect authentication, we extract the `id_token` from the session where the `omniauth-proconnect` gem stores it:

```ruby
def authenticate_user(identity_federator: 'mon_compte_pro')
  organizer = call_authenticator(identity_federator)
  
  # Extract id_token from ProConnect for logout
  # The omniauth-proconnect gem stores id_token in session at "omniauth.pc.id_token"
  id_token = if organizer.identity_federator == 'pro_connect'
    session["omniauth.pc.id_token"]
  end
  
  sign_in(organizer.user, identity_federator: organizer.identity_federator, 
          identity_provider_uid: organizer.identity_provider_uid, id_token: id_token)
end
```

### 3. Logout Flow

#### 3.1 Building the Logout URL

The `proconnect_signout_url` method constructs the proper OIDC end_session endpoint URL:

```ruby
def proconnect_signout_url
  # Generate state parameter for CSRF protection
  logout_state = SecureRandom.hex(32)
  session[:logout_state] = logout_state
  
  # Build logout URL according to ProConnect OIDC specification
  proconnect_domain = Rails.application.credentials.proconnect_url
  params = {
    id_token_hint: session[:id_token],
    state: logout_state,
    post_logout_redirect_uri: after_logout_url
  }
  
  "#{proconnect_domain}/session/end?#{params.to_query}"
end
```

#### 3.2 Logout Callback

After ProConnect terminates the session, it redirects back to the `logout_callback` action:

```ruby
def logout_callback
  # Verify state parameter for CSRF protection
  if params[:state].present? && params[:state] != session[:logout_state]
    redirect_to root_path, alert: t('sessions.logout.invalid_state')
    return
  end
  
  # Clear logout session data
  session.delete(:logout_state)
  session.delete(:id_token)
  
  redirect_to root_path, notice: t('sessions.logout.success')
end
```

### 4. Routes (`config/routes.rb`)

Added a new route for the post-logout callback:

```ruby
get 'compte/deconnexion', to: 'sessions#destroy', as: :signout
get 'compte/deconnexion/callback', to: 'sessions#logout_callback', as: :logout_callback
```

### 5. View Updates (`app/views/layouts/header/_tools.html.erb`)

Disabled Turbo on the logout link to ensure proper redirect handling:

```erb
<a class="fr-link fr-icon-logout-box-r-fill" id="signout_button" 
   href="<%= signout_path %>" data-turbo="false">
  <%= t('.links.sign_out.title') %>
</a>
```

### 6. Translations (`config/locales/fr.yml`)

Added French translations for logout messages:

```yaml
sessions:
  logout:
    success: Vous avez été déconnecté avec succès
    invalid_state: "Erreur lors de la déconnexion : état invalide"
```

## Compliance with ProConnect Specification

This implementation follows the ProConnect OIDC specification:

1. ✅ **Stores `id_token`** during authentication
2. ✅ **Uses proper end_session endpoint**: `/api/v2/session/end`
3. ✅ **Includes required parameters**:
   - `id_token_hint`: The stored ID token
   - `state`: CSRF protection token
   - `post_logout_redirect_uri`: Callback URL after logout
4. ✅ **Redirects in browser**: Ensures ProConnect and Identity Provider sessions are terminated
5. ✅ **Verifies state on callback**: CSRF protection
6. ✅ **Cleans up session data**: Removes all authentication-related session data

## Testing

The implementation can be tested by:

1. Logging in with ProConnect
2. Clicking "Se déconnecter"
3. Verifying in browser network tab:
   - Request to ProConnect's `/api/v2/session/end` endpoint
   - Redirect back to the callback URL
   - Final redirect to home page with success message

## Key Discovery

The `omniauth-proconnect` gem (v0.5) stores the `id_token` in the session at `session["omniauth.pc.id_token"]`, not in the standard OmniAuth credentials hash. This is why we extract it from the session during authentication rather than from the OAuth callback payload.

