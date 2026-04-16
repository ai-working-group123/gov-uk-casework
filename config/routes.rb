Rails.application.routes.draw do
  resources :teams
  resources :caseworkers
  resources :policy_references
  resources :cases do
    resources :evidences
    resources :case_notes, only: [:index, :show, :create, :new, :edit, :update, :destroy]
    resources :actions do
      resources :correspondences
    end
    resources :evidence_requests do
      resources :evidence_request_items
    end
  end

  root "cases#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
