ClogsDb::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => 'users/registrations' }

  devise_scope :user do
    get 'users', to: 'users/registrations#index'
    put 'users/:id/toggle_approved', to: 'users/registrations#toggle_approved', as: 'toggle_user'
    delete 'users/:id', to: 'users/registrations#destroy_other', as: 'destroy_other_user'
  end

  resources :members do
    put 'toggle_paid/:fee', on: :member, constraints: {fee: /subs|show|concert/}, action: 'toggle_paid', as: 'toggle_paid'
  end
  resources :mailing_lists


  scope 'mail_shots' do
    get 'new/:mailing_list_id', to: 'mail_shots#new', as: 'new_mail_shot', defaults: {mailing_list_id: 1}
    post 'create', to: 'mail_shots#create', as: 'create_mail_shot'
  end

  post 'parse_mail', to: 'inbound_parse#parse'

  root to: 'members#index'

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
