module Devise
  module LDAP
    class AttributeMapper

      DEFAULT_MAPPING = { email: 'mail',
                          password: 'userPassword',
                          firstname: 'givenName',
                          lastname: 'sn',
      }

      def initialize(user, mapping = DEFAULT_MAPPING)
        @user = user
        @mapping = mapping
      end

      def get_attributes
        @user.attributes.reject{ |p| !@mapping.include? p.to_sym }
      end

      def get_ldap_attribute(key)
        @mapping[key]
      end

    end
  end
end