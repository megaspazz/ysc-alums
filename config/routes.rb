YscAlums::Application.routes.draw do

  get "users/new"

  resources :users
  match '/settings', :to => 'users#settings'
  match '/users/:id/change-settings', :to => 'users#change_settings', :as => :change_settings    # second one corresponds to actual method
  match '/users/:id/change-password', :to => 'users#change_password', :as => :change_password
  match '/users/:id/make-admin', :to => 'users#make_admin', :as => :make_admin

  match '/confirm/:confirm_code', :to => 'users#confirm_code', :as => :confirm_code
  match '/resend-confirmation', :to => 'users#resend_confirmation', :as => :resend_confirmation

  match '/register', :to => 'users#new'

  resources :simple_emails, :only => [:new, :create, :destroy]
  match '/users/:id/email', :to => 'simple_emails#new', :as => :send_email

  resources :sessions, :only => [:new, :create, :destroy]    # destroys session, not user

  resources :routes, :only => [:create, :destroy]

  match '/login', :to => 'sessions#new'
  match '/logout', :to => 'sessions#destroy', :via => :delete

  match "/home", :to => 'static_pages#home'
  match "/about", :to => 'static_pages#about'
  match "/help", :to => 'static_pages#help'
  match "/contact", :to => 'static_pages#contact'
  match "/test", :to => 'static_pages#test'

  root :to => 'static_pages#home'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
