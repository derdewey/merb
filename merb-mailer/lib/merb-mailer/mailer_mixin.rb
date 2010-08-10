module Merb
  module MailerMixin

    # Sends mail via a {Merb::MailController}.
    #
    # @param [Class] klass The mailer class.
    # @param [#to_s] method The method to call on the mailer.
    # @param [Hash] mail_params Mailing parameters, e.g. `:to` and `:cc`.
    #   See {Merb::MailController#dispatch_and_deliver} for details.
    # @param [Hash] send_params Params to send to the mailer. Defaults
    #   to the params of the current controller.
    #
    # @example
    #   # Send an email via the FooMailer's bar method.
    #   send_mail FooMailer, :bar, :from => "foo@bar.com", :to => "baz@bat.com"
    def send_mail(klass, method, mail_params, send_params = nil)
      klass.new(send_params || params, self).dispatch_and_deliver(method, mail_params)
    end
      
  end
end
