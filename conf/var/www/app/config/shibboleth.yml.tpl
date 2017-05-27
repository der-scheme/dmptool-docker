production:
  #The host for the web application, used to construct the target for the shibboleth id
  #provider's return.
  host: ${HOSTNAME}
  uid_field: eppn
  info_fields:
    email: mail
    first_name: givenName
    last_name: sn
    name: displayName
    identity_provider: shib_identity_provider
