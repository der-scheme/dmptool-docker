<SPConfig xmlns="urn:mace:shibboleth:2.0:native:sp:config"
    xmlns:conf="urn:mace:shibboleth:2.0:native:sp:config"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    clockSkew="180">

    <!--
    By default, in-memory StorageService, ReplayCache, ArtifactMap, and SessionCache
    are used. See example-shibboleth2.xml for samples of explicitly configuring them.
    -->

    <!--
    To customize behavior for specific resources on Apache, and to link vhosts or
    resources to ApplicationOverride settings below, use web server options/commands.
    See https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPConfigurationElements for help.

    For examples with the RequestMap XML syntax instead, see the example-shibboleth2.xml
    file, and the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapHowTo topic.
    -->
    <RequestMapper type="XML">
        <RequestMap>
            <Host name="${HOSTNAME}" redirectToSSL="443"
                  authType="shibboleth" requireSession="true">
                <Path name="/auth/shibboleth/callback" />
            </Host>
        </RequestMap>
    </RequestMapper>

    <!-- The ApplicationDefaults element is where most of Shibboleth's SAML bits are defined. -->
    <ApplicationDefaults entityID="https://${HOSTNAME}/Shibboleth.sso/Metadata"
                         REMOTE_USER="eppn persistent-id targeted-id">

        <!--
        Controls session lifetimes, address checks, cookie handling, and the protocol handlers.
        You MUST supply an effectively unique handlerURL value for each of your applications.
        The value defaults to /Shibboleth.sso, and should be a relative path, with the SP computing
        a relative value based on the virtual host. Using handlerSSL="true", the default, will force
        the protocol to be https. You should also set cookieProps to "https" for SSL-only sites.
        Note that while we default checkAddress to "false", this has a negative impact on the
        security of your site. Stealing sessions via cookie theft is much easier with this disabled.
        -->
        <Sessions lifetime="28800" timeout="3600" relayState="ss:mem"
                  checkAddress="false" consistentAddress="true"
                  handlerSSL="true" cookieProps="https">

            <!--
            Configures SSO for a default IdP. To allow for >1 IdP, remove
            entityID property and adjust discoveryURL to point to discovery service.
            (Set discoveryProtocol to "WAYF" for legacy Shibboleth WAYF support.)
            You can also override entityID on /Login query string, or in RequestMap/htaccess.
            -->
            <SSO discoveryProtocol="SAMLDS" discoveryURL="${SHIB_DISCOVERY_URL}">
              SAML2
            </SSO>

            <!-- SAML and local-only logout. -->
            <Logout>SAML2 Local</Logout>

            <!-- Extension service that generates "approximate" metadata based on SP configuration. -->
            <Handler type="MetadataGenerator" Location="/Metadata" signing="false"/>

            <!-- Status reporting service. -->
            <Handler type="Status" Location="/Status" acl="127.0.0.1 ::1"/>

            <!-- Session diagnostic service. -->
            <Handler type="Session" Location="/Session" showAttributeValues="false"/>

            <!-- JSON feed of discovery information. -->
            <Handler type="DiscoveryFeed" Location="/DiscoFeed"/>
        </Sessions>

        <!--
        Allows overriding of error template information/filenames. You can
        also add attributes with values that can be plugged into the templates.
        -->
        <Errors supportContact="${SHIB_SUPPORT_CONTACT}"
            helpLocation="/about.html"
            styleSheet="/shibboleth-sp/main.css"/>

        <!-- Example of remotely supplied batch of signed metadata. -->
        <!--
        <MetadataProvider type="XML" uri="http://federation.org/federation-metadata.xml"
              backingFilePath="federation-metadata.xml" reloadInterval="7200">
            <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
            <MetadataFilter type="Signature" certificate="fedsigner.pem"/>
        </MetadataProvider>
        -->

        <!-- Example of locally maintained metadata. -->
        <!--
        <MetadataProvider type="XML" file="partner-metadata.xml"/>
        -->
        <MetadataProvider type="Chaining">
          <MetadataProvider type="XML" uri="${SHIB_METADATA_PROVIDER_URI}"
                            backingFilePath="${SHIB_METADATA_PROVIDER_BFP}" reloadInterval="7200">
            <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
            <MetadataFilter type="Signature" certificate="/etc/ssl/extern/${SHIB_METADATA_PROVIDER_CERT}"/>
          </MetadataProvider>
       </MetadataProvider>

        <!-- Map to extract attributes from SAML assertions. -->
        <AttributeExtractor type="XML" validate="true" reloadChanges="false" path="attribute-map.xml"/>

        <!-- Use a SAML query if no attributes are supplied during SSO. -->
        <AttributeResolver type="Query" subjectMatch="true"/>

        <!-- Default filtering policy for recognized attributes, lets other data pass. -->
        <AttributeFilter type="XML" validate="true" path="attribute-policy.xml"/>

        <!-- Simple file-based resolver for using a single keypair. -->
        <CredentialResolver type="File" key="sp-key.pem" certificate="sp-cert.pem"/>

        <!--
        The default settings can be overridden by creating ApplicationOverride elements (see
        the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApplicationOverride topic).
        Resource requests are mapped by web server commands, or the RequestMapper, to an
        applicationId setting.

        Example of a second application (for a second vhost) that has a different entityID.
        Resources on the vhost would map to an applicationId of "admin":
        -->
        <!--
        <ApplicationOverride id="admin" entityID="https://admin.example.org/shibboleth"/>
        -->
    </ApplicationDefaults>

    <!-- Policies that determine how to process and authenticate runtime messages. -->
    <SecurityPolicyProvider type="XML" validate="true" path="security-policy.xml"/>

    <!-- Low-level configuration about protocols and bindings available for use. -->
    <ProtocolProvider type="XML" validate="true" reloadChanges="false" path="protocols.xml"/>

</SPConfig>
