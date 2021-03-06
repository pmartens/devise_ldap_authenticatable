require "net/ldap"

module Devise
  module LDAP
    DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY = 'uniqueMember'
    DEFAULT_MAIL_GROUP_UNIQUE_MEMBER_LIST_KEY = 'mailLocalAddress'
    DEFAULT_USER_UNIQUE_LIST_KEY = 'uid'

    module Adapter
      def self.valid_credentials?(login, password_plaintext)
        options = {:login => login,
                   :password => password_plaintext,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.authorized?
      end

      def self.update_attributes(login, user, attribute_mappings = nil)
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        mapper = Devise::LDAP::AttributeMapper.new(user, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
            resource.set_param(mapper.get_ldap_attribute(key.to_sym), value) unless key.nil?
        end
      end

      def self.update_password(login, new_password)
        options = {:login => login,
                   :new_password => new_password,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.change_password! if new_password.present?
      end

      def self.update_mailbox_password(login, email, new_password, mailbox_attribute = nil)
        self.ldap_connect(login).update_personal_mailbox_password(email, new_password, mailbox_attribute)
      end

      def self.update_own_password(login, new_password, current_password)
        set_ldap_param(login, :userPassword, ::Devise.ldap_auth_password_builder.call(new_password), current_password)
      end

      def self.upload_photo(login, photo_attribute, file)
        return unless File.exist? file
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.set_param(photo_attribute, IO.binread(file))
      end

      def self.ldap_connect(login)
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        Devise::LDAP::Connection.new(options)
      end

      def self.valid_login?(login)
        self.ldap_connect(login).valid_login?
      end

      def self.get_groups(login, group_attribute = nil)
        self.ldap_connect(login).user_groups(group_attribute)
      end

      def self.groups_for_user(login, user_value, group_attribute)
        self.ldap_connect(login).groups_for_user(user_value, group_attribute)
      end

      def self.get_all_groups(login, group_attribute = nil)
        self.ldap_connect(login).all_groups(group_attribute)
      end

      def self.get_personal_mailbox(login, email, mailbox_attribute = nil )
        self.ldap_connect(login).personal_mailbox(email, mailbox_attribute)
      end

      def self.get_user(login, user_value, find_attribute = nil)
        self.ldap_connect(login).user(user_value, find_attribute)
      end

      def self.get_users(login)
        self.ldap_connect(login).users
      end

      def self.in_ldap_group?(login, group_name, group_attribute = nil)
        self.ldap_connect(login).in_group?(group_name, group_attribute)
      end

      def self.get_dn(login)
        self.ldap_connect(login).dn
      end

      def self.set_ldap_param(login, param, new_value, password = nil)
        options = { :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password }

        resource = Devise::LDAP::Connection.new(options)
        resource.set_param(param, new_value)
      end

      def self.delete_ldap_param(login, param, password = nil)
        options = { :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password }

        resource = Devise::LDAP::Connection.new(options)
        resource.delete_param(param)
      end

      def self.get_ldap_param(login,param)
        resource = self.ldap_connect(login)
        resource.ldap_param_value(param)
      end

      def self.get_ldap_extended_property(login,attribute)
        resource = self.ldap_connect(login)
        resource.get_extended_propertie attribute
      end

      def self.get_ldap_entry(login)
        self.ldap_connect(login).search_for_login
      end

    end

  end

end
