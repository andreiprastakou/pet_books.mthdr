Frontend::Engine.routes.draw do
  root to: 'home#index'

  # Keep asset requests out of the SPA fallback. If the Shakapacker dev server is
  # unreachable, /packs/* falls through to Rails; matching it here answered with the SPA
  # document and a 200, which the browser rejects as a MIME type mismatch. Declining the
  # route makes a missing pack surface as a plain 404 instead.
  get '*path',
      to: 'home#index',
      format: :html,
      constraints: ->(request) { !request.path.start_with?('/packs') }
end
