EMAIL_PATTERN = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
unless Rails.env.production?
  ENV['SOCIETY_EMAIL'] = 'clogs@example.com'
  ENV['ADMIN_EMAIL'] = 'foo@example.com'
  ENV['DEVISE_SECRET'] = '5ec237'
  ENV['SECRET_KEY_BASE'] = 'a11bas5e'
end
