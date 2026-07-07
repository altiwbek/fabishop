class ApplicationMailer < ActionMailer::Base
  default from: "electronics Store <orders@electronics.store>"
  layout "mailer"
end
