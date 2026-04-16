Rails.application.routes.draw do
  scope "admin" do
    resources :teams
    resources :caseworkers
    resources :policy_references
    resources :cases do
      member do
        post :evaluate
        post :run_workflow
      end
      resources :evidences
      resources :case_notes, only: [ :index, :show, :create, :new, :edit, :update, :destroy ]
      resources :actions do
        resources :correspondences
      end
      resources :evidence_requests do
        resources :evidence_request_items
      end
    end

    resources :case_type_configs, only: [ :new, :create, :show, :index, :edit, :update ] do
      member do
        get :questions
        post :answer
        get :review
        post :submit_review
        get :suggestions
        post :apply_suggestions
        get :finalise
        post :publish
        get :processing
        post :generate
      end
    end
  end

  scope "public" do
    get  "lookup",                                    to: "lookup#index",       as: :public_lookup
    get  "lookup/:reference",                         to: "lookup#show",        as: :public_lookup_case
    get  "lookup/:reference/upload/:item_id",         to: "lookup#upload_form", as: :public_lookup_upload_form
    post "lookup/:reference/upload/:item_id",         to: "lookup#upload",      as: :public_lookup_upload
  end

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
