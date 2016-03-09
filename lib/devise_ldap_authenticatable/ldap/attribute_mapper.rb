module Devise
  module LDAP
    class AttributeMapper

      DEFAULT_MAPPING = { email: 'mail',
                          password: 'userPassword',
                          firstname: 'givenName',
                          lastname: 'sn',
      }

      def initialize(params, mapping = DEFAULT_MAPPING)
        @attributes = params
        @mapping = mapping
      end

      def get_attributes
        @attributes.reject{ |p| !@mapping.include? p.to_sym }
      end

      def get_ldap_attribute(key)
        @mapping[key]
      end

    end
  end
end