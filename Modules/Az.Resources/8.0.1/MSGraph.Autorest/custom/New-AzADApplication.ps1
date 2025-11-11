
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Adds new entity to applications
.Description
Adds new entity to applications
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

ADDIN <IMicrosoftGraphAddIn[]>: Defines custom behavior that a consuming service can use to call an app in specific contexts. For example, applications that can render file streams may set the addIns property for its 'FileHandler' functionality. This will let services like Office 365 call the application in the context of a document the user is working on.
  [Id <String>]: 
  [Property <IMicrosoftGraphKeyValue[]>]: 
    [Key <String>]: Key.
    [Value <String>]: Value.
  [Type <String>]: 

API <IMicrosoftGraphApiApplication>: apiApplication
  [(Any) <Object>]: This indicates any property can be added to this object.
  [AcceptMappedClaim <Boolean?>]: When true, allows an application to use claims mapping without specifying a custom signing key.
  [KnownClientApplication <String[]>]: Used for bundling consent if you have a solution that contains two parts: a client app and a custom web API app. If you set the appID of the client app to this value, the user only consents once to the client app. Azure AD knows that consenting to the client means implicitly consenting to the web API and automatically provisions service principals for both APIs at the same time. Both the client and the web API app must be registered in the same tenant.
  [Oauth2PermissionScope <IMicrosoftGraphPermissionScope[]>]: The definition of the delegated permissions exposed by the web API represented by this application registration. These delegated permissions may be requested by a client application, and may be granted by users or administrators during consent. Delegated permissions are sometimes referred to as OAuth 2.0 scopes.
    [AdminConsentDescription <String>]: A description of the delegated permissions, intended to be read by an administrator granting the permission on behalf of all users. This text appears in tenant-wide admin consent experiences.
    [AdminConsentDisplayName <String>]: The permission's title, intended to be read by an administrator granting the permission on behalf of all users.
    [Id <String>]: Unique delegated permission identifier inside the collection of delegated permissions defined for a resource application.
    [IsEnabled <Boolean?>]: When creating or updating a permission, this property must be set to true (which is the default). To delete a permission, this property must first be set to false.  At that point, in a subsequent call, the permission may be removed.
    [Origin <String>]: 
    [Type <String>]: Specifies whether this delegated permission should be considered safe for non-admin users to consent to on behalf of themselves, or whether an administrator should be required for consent to the permissions. This will be the default behavior, but each customer can choose to customize the behavior in their organization (by allowing, restricting or limiting user consent to this delegated permission.)
    [UserConsentDescription <String>]: A description of the delegated permissions, intended to be read by a user granting the permission on their own behalf. This text appears in consent experiences where the user is consenting only on behalf of themselves.
    [UserConsentDisplayName <String>]: A title for the permission, intended to be read by a user granting the permission on their own behalf. This text appears in consent experiences where the user is consenting only on behalf of themselves.
    [Value <String>]: Specifies the value to include in the scp (scope) claim in access tokens. Must not exceed 120 characters in length. Allowed characters are : ! # $ % & ' ( ) * + , - . / : ;  =  ? @ [ ] ^ + _  {  } ~, as well as characters in the ranges 0-9, A-Z and a-z. Any other character, including the space character, are not allowed. May not begin with ..
  [PreAuthorizedApplication <IMicrosoftGraphPreAuthorizedApplication[]>]: Lists the client applications that are pre-authorized with the specified delegated permissions to access this application's APIs. Users are not required to consent to any pre-authorized application (for the permissions specified). However, any additional permissions not listed in preAuthorizedApplications (requested through incremental consent for example) will require user consent.
    [AppId <String>]: The unique identifier for the application.
    [DelegatedPermissionId <String[]>]: The unique identifier for the oauth2PermissionScopes the application requires.
  [RequestedAccessTokenVersion <Int32?>]: Specifies the access token version expected by this resource. This changes the version and format of the JWT produced independent of the endpoint or client used to request the access token.  The endpoint used, v1.0 or v2.0, is chosen by the client and only impacts the version of id_tokens. Resources need to explicitly configure requestedAccessTokenVersion to indicate the supported access token format.  Possible values for requestedAccessTokenVersion are 1, 2, or null. If the value is null, this defaults to 1, which corresponds to the v1.0 endpoint.  If signInAudience on the application is configured as AzureADandPersonalMicrosoftAccount, the value for this property must be 2

APPROLE <IMicrosoftGraphAppRole[]>: The collection of roles assigned to the application. With app role assignments, these roles can be assigned to users, groups, or service principals associated with other applications. Not nullable.
  [AllowedMemberType <String[]>]: Specifies whether this app role can be assigned to users and groups (by setting to ['User']), to other application's (by setting to ['Application'], or both (by setting to ['User', 'Application']). App roles supporting assignment to other applications' service principals are also known as application permissions. The 'Application' value is only supported for app roles defined on application entities.
  [Description <String>]: The description for the app role. This is displayed when the app role is being assigned and, if the app role functions as an application permission, during  consent experiences.
  [DisplayName <String>]: Display name for the permission that appears in the app role assignment and consent experiences.
  [Id <String>]: Unique role identifier inside the appRoles collection. When creating a new app role, a new Guid identifier must be provided.
  [IsEnabled <Boolean?>]: When creating or updating an app role, this must be set to true (which is the default). To delete a role, this must first be set to false.  At that point, in a subsequent call, this role may be removed.
  [Origin <String>]: Specifies if the app role is defined on the application object or on the servicePrincipal entity. Must not be included in any POST or PATCH requests. Read-only.
  [Value <String>]: Specifies the value to include in the roles claim in ID tokens and access tokens authenticating an assigned user or service principal. Must not exceed 120 characters in length. Allowed characters are : ! # $ % & ' ( ) * + , - . / : ;  =  ? @ [ ] ^ + _  {  } ~, as well as characters in the ranges 0-9, A-Z and a-z. Any other character, including the space character, are not allowed. May not begin with ..

BODY <IMicrosoftGraphApplication>: Represents an Azure Active Directory object. The directoryObject type is the base type for many other directory entity types.
  [(Any) <Object>]: This indicates any property can be added to this object.
  [DeletedDateTime <DateTime?>]: 
  [AddIn <IMicrosoftGraphAddIn[]>]: Defines custom behavior that a consuming service can use to call an app in specific contexts. For example, applications that can render file streams may set the addIns property for its 'FileHandler' functionality. This will let services like Office 365 call the application in the context of a document the user is working on.
    [Id <String>]: 
    [Property <IMicrosoftGraphKeyValue[]>]: 
      [Key <String>]: Key.
      [Value <String>]: Value.
    [Type <String>]: 
  [Api <IMicrosoftGraphApiApplication>]: apiApplication
    [(Any) <Object>]: This indicates any property can be added to this object.
    [AcceptMappedClaim <Boolean?>]: When true, allows an application to use claims mapping without specifying a custom signing key.
    [KnownClientApplication <String[]>]: Used for bundling consent if you have a solution that contains two parts: a client app and a custom web API app. If you set the appID of the client app to this value, the user only consents once to the client app. Azure AD knows that consenting to the client means implicitly consenting to the web API and automatically provisions service principals for both APIs at the same time. Both the client and the web API app must be registered in the same tenant.
    [Oauth2PermissionScope <IMicrosoftGraphPermissionScope[]>]: The definition of the delegated permissions exposed by the web API represented by this application registration. These delegated permissions may be requested by a client application, and may be granted by users or administrators during consent. Delegated permissions are sometimes referred to as OAuth 2.0 scopes.
      [AdminConsentDescription <String>]: A description of the delegated permissions, intended to be read by an administrator granting the permission on behalf of all users. This text appears in tenant-wide admin consent experiences.
      [AdminConsentDisplayName <String>]: The permission's title, intended to be read by an administrator granting the permission on behalf of all users.
      [Id <String>]: Unique delegated permission identifier inside the collection of delegated permissions defined for a resource application.
      [IsEnabled <Boolean?>]: When creating or updating a permission, this property must be set to true (which is the default). To delete a permission, this property must first be set to false.  At that point, in a subsequent call, the permission may be removed.
      [Origin <String>]: 
      [Type <String>]: Specifies whether this delegated permission should be considered safe for non-admin users to consent to on behalf of themselves, or whether an administrator should be required for consent to the permissions. This will be the default behavior, but each customer can choose to customize the behavior in their organization (by allowing, restricting or limiting user consent to this delegated permission.)
      [UserConsentDescription <String>]: A description of the delegated permissions, intended to be read by a user granting the permission on their own behalf. This text appears in consent experiences where the user is consenting only on behalf of themselves.
      [UserConsentDisplayName <String>]: A title for the permission, intended to be read by a user granting the permission on their own behalf. This text appears in consent experiences where the user is consenting only on behalf of themselves.
      [Value <String>]: Specifies the value to include in the scp (scope) claim in access tokens. Must not exceed 120 characters in length. Allowed characters are : ! # $ % & ' ( ) * + , - . / : ;  =  ? @ [ ] ^ + _  {  } ~, as well as characters in the ranges 0-9, A-Z and a-z. Any other character, including the space character, are not allowed. May not begin with ..
    [PreAuthorizedApplication <IMicrosoftGraphPreAuthorizedApplication[]>]: Lists the client applications that are pre-authorized with the specified delegated permissions to access this application's APIs. Users are not required to consent to any pre-authorized application (for the permissions specified). However, any additional permissions not listed in preAuthorizedApplications (requested through incremental consent for example) will require user consent.
      [AppId <String>]: The unique identifier for the application.
      [DelegatedPermissionId <String[]>]: The unique identifier for the oauth2PermissionScopes the application requires.
    [RequestedAccessTokenVersion <Int32?>]: Specifies the access token version expected by this resource. This changes the version and format of the JWT produced independent of the endpoint or client used to request the access token.  The endpoint used, v1.0 or v2.0, is chosen by the client and only impacts the version of id_tokens. Resources need to explicitly configure requestedAccessTokenVersion to indicate the supported access token format.  Possible values for requestedAccessTokenVersion are 1, 2, or null. If the value is null, this defaults to 1, which corresponds to the v1.0 endpoint.  If signInAudience on the application is configured as AzureADandPersonalMicrosoftAccount, the value for this property must be 2
  [AppRole <IMicrosoftGraphAppRole[]>]: The collection of roles assigned to the application. With app role assignments, these roles can be assigned to users, groups, or service principals associated with other applications. Not nullable.
    [AllowedMemberType <String[]>]: Specifies whether this app role can be assigned to users and groups (by setting to ['User']), to other application's (by setting to ['Application'], or both (by setting to ['User', 'Application']). App roles supporting assignment to other applications' service principals are also known as application permissions. The 'Application' value is only supported for app roles defined on application entities.
    [Description <String>]: The description for the app role. This is displayed when the app role is being assigned and, if the app role functions as an application permission, during  consent experiences.
    [DisplayName <String>]: Display name for the permission that appears in the app role assignment and consent experiences.
    [Id <String>]: Unique role identifier inside the appRoles collection. When creating a new app role, a new Guid identifier must be provided.
    [IsEnabled <Boolean?>]: When creating or updating an app role, this must be set to true (which is the default). To delete a role, this must first be set to false.  At that point, in a subsequent call, this role may be removed.
    [Origin <String>]: Specifies if the app role is defined on the application object or on the servicePrincipal entity. Must not be included in any POST or PATCH requests. Read-only.
    [Value <String>]: Specifies the value to include in the roles claim in ID tokens and access tokens authenticating an assigned user or service principal. Must not exceed 120 characters in length. Allowed characters are : ! # $ % & ' ( ) * + , - . / : ;  =  ? @ [ ] ^ + _  {  } ~, as well as characters in the ranges 0-9, A-Z and a-z. Any other character, including the space character, are not allowed. May not begin with ..
  [ApplicationTemplateId <String>]: Unique identifier of the applicationTemplate.
  [CreatedOnBehalfOfDeletedDateTime <DateTime?>]: 
  [Description <String>]: An optional description of the application. Returned by default. Supports $filter (eq, ne, NOT, ge, le, startsWith) and $search.
  [DisabledByMicrosoftStatus <String>]: Specifies whether Microsoft has disabled the registered application. Possible values are: null (default value), NotDisabled, and DisabledDueToViolationOfServicesAgreement (reasons may include suspicious, abusive, or malicious activity, or a violation of the Microsoft Services Agreement).  Supports $filter (eq, ne, NOT).
  [DisplayName <String>]: The display name for the application. Supports $filter (eq, ne, NOT, ge, le, in, startsWith), $search, and $orderBy.
  [GroupMembershipClaim <String>]: Configures the groups claim issued in a user or OAuth 2.0 access token that the application expects. To set this attribute, use one of the following string values: None, SecurityGroup (for security groups and Azure AD roles), All (this gets all security groups, distribution groups, and Azure AD directory roles that the signed-in user is a member of).
  [HomeRealmDiscoveryPolicy <IMicrosoftGraphHomeRealmDiscoveryPolicy[]>]: 
    [AppliesTo <IMicrosoftGraphDirectoryObject[]>]: 
      [DeletedDateTime <DateTime?>]: 
    [Definition <String[]>]: A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.
    [IsOrganizationDefault <Boolean?>]: If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.
    [Description <String>]: Description for this policy.
    [DisplayName <String>]: Display name for this policy.
    [DeletedDateTime <DateTime?>]: 
  [IdentifierUri <String[]>]: The URIs that identify the application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant. For more information, see Application Objects and Service Principal Objects. The any operator is required for filter expressions on multi-valued properties. Not nullable. Supports $filter (eq, ne, ge, le, startsWith).
  [Info <IMicrosoftGraphInformationalUrl>]: informationalUrl
    [(Any) <Object>]: This indicates any property can be added to this object.
    [LogoUrl <String>]: CDN URL to the application's logo, Read-only.
    [MarketingUrl <String>]: Link to the application's marketing page. For example, https://www.contoso.com/app/marketing
    [PrivacyStatementUrl <String>]: Link to the application's privacy statement. For example, https://www.contoso.com/app/privacy
    [SupportUrl <String>]: Link to the application's support page. For example, https://www.contoso.com/app/support
    [TermsOfServiceUrl <String>]: Link to the application's terms of service statement. For example, https://www.contoso.com/app/termsofservice
  [IsDeviceOnlyAuthSupported <Boolean?>]: Specifies whether this application supports device authentication without a user. The default is false.
  [IsFallbackPublicClient <Boolean?>]: Specifies the fallback application type as public client, such as an installed application running on a mobile device. The default value is false which means the fallback application type is confidential client such as a web app. There are certain scenarios where Azure AD cannot determine the client application type. For example, the ROPC flow where the application is configured without specifying a redirect URI. In those cases Azure AD interprets the application type based on the value of this property.
  [KeyCredentials <IMicrosoftGraphKeyCredential[]>]: The collection of key credentials associated with the application. Not nullable. Supports $filter (eq, NOT, ge, le).
    [CustomKeyIdentifier <Byte[]>]: Custom key identifier
    [DisplayName <String>]: Friendly name for the key. Optional.
    [EndDateTime <DateTime?>]: The date and time at which the credential expires.The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z
    [Key <Byte[]>]: Value for the key credential. Should be a base 64 encoded value.
    [KeyId <String>]: The unique identifier (GUID) for the key.
    [StartDateTime <DateTime?>]: The date and time at which the credential becomes valid.The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z
    [Type <String>]: The type of key credential; for example, 'Symmetric'.
    [Usage <String>]: A string that describes the purpose for which the key can be used; for example, 'Verify'.
  [Logo <Byte[]>]: The main logo for the application. Not nullable.
  [Note <String>]: Notes relevant for the management of the application.
  [Oauth2RequirePostResponse <Boolean?>]: 
  [OptionalClaim <IMicrosoftGraphOptionalClaims>]: optionalClaims
    [(Any) <Object>]: This indicates any property can be added to this object.
    [AccessToken <IMicrosoftGraphOptionalClaim[]>]: The optional claims returned in the JWT access token.
      [AdditionalProperty <String[]>]: Additional properties of the claim. If a property exists in this collection, it modifies the behavior of the optional claim specified in the name property.
      [Essential <Boolean?>]: If the value is true, the claim specified by the client is necessary to ensure a smooth authorization experience for the specific task requested by the end user. The default value is false.
      [Name <String>]: The name of the optional claim.
      [Source <String>]: The source (directory object) of the claim. There are predefined claims and user-defined claims from extension properties. If the source value is null, the claim is a predefined optional claim. If the source value is user, the value in the name property is the extension property from the user object.
    [IdToken <IMicrosoftGraphOptionalClaim[]>]: The optional claims returned in the JWT ID token.
    [Saml2Token <IMicrosoftGraphOptionalClaim[]>]: The optional claims returned in the SAML token.
  [ParentalControlSetting <IMicrosoftGraphParentalControlSettings>]: parentalControlSettings
    [(Any) <Object>]: This indicates any property can be added to this object.
    [CountriesBlockedForMinor <String[]>]: Specifies the two-letter ISO country codes. Access to the application will be blocked for minors from the countries specified in this list.
    [LegalAgeGroupRule <String>]: Specifies the legal age group rule that applies to users of the app. Can be set to one of the following values: ValueDescriptionAllowDefault. Enforces the legal minimum. This means parental consent is required for minors in the European Union and Korea.RequireConsentForPrivacyServicesEnforces the user to specify date of birth to comply with COPPA rules. RequireConsentForMinorsRequires parental consent for ages below 18, regardless of country minor rules.RequireConsentForKidsRequires parental consent for ages below 14, regardless of country minor rules.BlockMinorsBlocks minors from using the app.
  [PasswordCredentials <IMicrosoftGraphPasswordCredential[]>]: The collection of password credentials associated with the application. Not nullable.
    [CustomKeyIdentifier <Byte[]>]: Do not use.
    [DisplayName <String>]: Friendly name for the password. Optional.
    [EndDateTime <DateTime?>]: The date and time at which the password expires represented using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Optional.
    [KeyId <String>]: The unique identifier for the password.
    [StartDateTime <DateTime?>]: The date and time at which the password becomes valid. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Optional.
  [PublicClient <IMicrosoftGraphPublicClientApplication>]: publicClientApplication
    [(Any) <Object>]: This indicates any property can be added to this object.
    [RedirectUri <String[]>]: Specifies the URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent.
  [RequiredResourceAccess <IMicrosoftGraphRequiredResourceAccess[]>]: Specifies the resources that the application needs to access. This property also specifies the set of OAuth permission scopes and application roles that it needs for each of those resources. This configuration of access to the required resources drives the consent experience. Not nullable. Supports $filter (eq, NOT, ge, le).
    [ResourceAccess <IMicrosoftGraphResourceAccess[]>]: The list of OAuth2.0 permission scopes and app roles that the application requires from the specified resource.
      [Id <String>]: The unique identifier for one of the oauth2PermissionScopes or appRole instances that the resource application exposes.
      [Type <String>]: Specifies whether the id property references an oauth2PermissionScopes or an appRole. Possible values are Scope or Role.
    [ResourceAppId <String>]: The unique identifier for the resource that the application requires access to.  This should be equal to the appId declared on the target resource application.
    [ServiceManagementReference <String>]: References application or service contact information from a Service or Asset Management database. Nullable.
  [SignInAudience <String>]: Specifies the Microsoft accounts that are supported for the current application. Supported values are: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount. See more in the table below. Supports $filter (eq, ne, NOT).
  [Spa <IMicrosoftGraphSpaApplication>]: spaApplication
    [(Any) <Object>]: This indicates any property can be added to this object.
    [RedirectUri <String[]>]: Specifies the URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent.
  [Tag <String[]>]: Custom strings that can be used to categorize and identify the application. Not nullable.Supports $filter (eq, NOT, ge, le, startsWith).
  [TokenEncryptionKeyId <String>]: Specifies the keyId of a public key from the keyCredentials collection. When configured, Azure AD encrypts all the tokens it emits by using the key this property points to. The application code that receives the encrypted token must use the matching private key to decrypt the token before it can be used for the signed-in user.
  [TokenIssuancePolicy <IMicrosoftGraphTokenIssuancePolicy[]>]: 
    [AppliesTo <IMicrosoftGraphDirectoryObject[]>]: 
    [Definition <String[]>]: A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.
    [IsOrganizationDefault <Boolean?>]: If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.
    [Description <String>]: Description for this policy.
    [DisplayName <String>]: Display name for this policy.
    [DeletedDateTime <DateTime?>]: 
  [TokenLifetimePolicy <IMicrosoftGraphTokenLifetimePolicy[]>]: The tokenLifetimePolicies assigned to this application. Supports $expand.
    [AppliesTo <IMicrosoftGraphDirectoryObject[]>]: 
    [Definition <String[]>]: A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.
    [IsOrganizationDefault <Boolean?>]: If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.
    [Description <String>]: Description for this policy.
    [DisplayName <String>]: Display name for this policy.
    [DeletedDateTime <DateTime?>]: 
  [Web <IMicrosoftGraphWebApplication>]: webApplication
    [(Any) <Object>]: This indicates any property can be added to this object.
    [HomePageUrl <String>]: Home page or landing page of the application.
    [ImplicitGrantSetting <IMicrosoftGraphImplicitGrantSettings>]: implicitGrantSettings
      [(Any) <Object>]: This indicates any property can be added to this object.
      [EnableAccessTokenIssuance <Boolean?>]: Specifies whether this web application can request an access token using the OAuth 2.0 implicit flow.
      [EnableIdTokenIssuance <Boolean?>]: Specifies whether this web application can request an ID token using the OAuth 2.0 implicit flow.
    [LogoutUrl <String>]: Specifies the URL that will be used by Microsoft's authorization service to logout an user using front-channel, back-channel or SAML logout protocols.
    [RedirectUri <String[]>]: Specifies the URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent.

HOMEREALMDISCOVERYPOLICY <IMicrosoftGraphHomeRealmDiscoveryPolicy[]>: .
  [AppliesTo <IMicrosoftGraphDirectoryObject[]>]: 
    [DeletedDateTime <DateTime?>]: 
  [Definition <String[]>]: A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.
  [IsOrganizationDefault <Boolean?>]: If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.
  [Description <String>]: Description for this policy.
  [DisplayName <String>]: Display name for this policy.
  [DeletedDateTime <DateTime?>]: 

INFO <IMicrosoftGraphInformationalUrl>: informationalUrl
  [(Any) <Object>]: This indicates any property can be added to this object.
  [LogoUrl <String>]: CDN URL to the application's logo, Read-only.
  [MarketingUrl <String>]: Link to the application's marketing page. For example, https://www.contoso.com/app/marketing
  [PrivacyStatementUrl <String>]: Link to the application's privacy statement. For example, https://www.contoso.com/app/privacy
  [SupportUrl <String>]: Link to the application's support page. For example, https://www.contoso.com/app/support
  [TermsOfServiceUrl <String>]: Link to the application's terms of service statement. For example, https://www.contoso.com/app/termsofservice

KEYCREDENTIALS <IMicrosoftGraphKeyCredential[]>: The collection of key credentials associated with the application. Not nullable. Supports $filter (eq, NOT, ge, le).
  [CustomKeyIdentifier <Byte[]>]: Custom key identifier
  [DisplayName <String>]: Friendly name for the key. Optional.
  [EndDateTime <DateTime?>]: The date and time at which the credential expires.The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z
  [Key <Byte[]>]: Value for the key credential. Should be a base 64 encoded value.
  [KeyId <String>]: The unique identifier (GUID) for the key.
  [StartDateTime <DateTime?>]: The date and time at which the credential becomes valid.The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z
  [Type <String>]: The type of key credential; for example, 'Symmetric'.
  [Usage <String>]: A string that describes the purpose for which the key can be used; for example, 'Verify'.

OPTIONALCLAIM <IMicrosoftGraphOptionalClaims>: optionalClaims
  [(Any) <Object>]: This indicates any property can be added to this object.
  [AccessToken <IMicrosoftGraphOptionalClaim[]>]: The optional claims returned in the JWT access token.
    [AdditionalProperty <String[]>]: Additional properties of the claim. If a property exists in this collection, it modifies the behavior of the optional claim specified in the name property.
    [Essential <Boolean?>]: If the value is true, the claim specified by the client is necessary to ensure a smooth authorization experience for the specific task requested by the end user. The default value is false.
    [Name <String>]: The name of the optional claim.
    [Source <String>]: The source (directory object) of the claim. There are predefined claims and user-defined claims from extension properties. If the source value is null, the claim is a predefined optional claim. If the source value is user, the value in the name property is the extension property from the user object.
  [IdToken <IMicrosoftGraphOptionalClaim[]>]: The optional claims returned in the JWT ID token.
  [Saml2Token <IMicrosoftGraphOptionalClaim[]>]: The optional claims returned in the SAML token.

PARENTALCONTROLSETTING <IMicrosoftGraphParentalControlSettings>: parentalControlSettings
  [(Any) <Object>]: This indicates any property can be added to this object.
  [CountriesBlockedForMinor <String[]>]: Specifies the two-letter ISO country codes. Access to the application will be blocked for minors from the countries specified in this list.
  [LegalAgeGroupRule <String>]: Specifies the legal age group rule that applies to users of the app. Can be set to one of the following values: ValueDescriptionAllowDefault. Enforces the legal minimum. This means parental consent is required for minors in the European Union and Korea.RequireConsentForPrivacyServicesEnforces the user to specify date of birth to comply with COPPA rules. RequireConsentForMinorsRequires parental consent for ages below 18, regardless of country minor rules.RequireConsentForKidsRequires parental consent for ages below 14, regardless of country minor rules.BlockMinorsBlocks minors from using the app.

PASSWORDCREDENTIALS <IMicrosoftGraphPasswordCredential[]>: The collection of password credentials associated with the application. Not nullable.
  [CustomKeyIdentifier <Byte[]>]: Do not use.
  [DisplayName <String>]: Friendly name for the password. Optional.
  [EndDateTime <DateTime?>]: The date and time at which the password expires represented using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Optional.
  [KeyId <String>]: The unique identifier for the password.
  [StartDateTime <DateTime?>]: The date and time at which the password becomes valid. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Optional.

PUBLICCLIENT <IMicrosoftGraphPublicClientApplication>: publicClientApplication
  [(Any) <Object>]: This indicates any property can be added to this object.
  [RedirectUri <String[]>]: Specifies the URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent.

REQUIREDRESOURCEACCESS <IMicrosoftGraphRequiredResourceAccess[]>: Specifies the resources that the application needs to access. This property also specifies the set of OAuth permission scopes and application roles that it needs for each of those resources. This configuration of access to the required resources drives the consent experience. Not nullable. Supports $filter (eq, NOT, ge, le).
  [ResourceAccess <IMicrosoftGraphResourceAccess[]>]: The list of OAuth2.0 permission scopes and app roles that the application requires from the specified resource.
    [Id <String>]: The unique identifier for one of the oauth2PermissionScopes or appRole instances that the resource application exposes.
    [Type <String>]: Specifies whether the id property references an oauth2PermissionScopes or an appRole. Possible values are Scope or Role.
  [ResourceAppId <String>]: The unique identifier for the resource that the application requires access to.  This should be equal to the appId declared on the target resource application.

SPA <IMicrosoftGraphSpaApplication>: spaApplication
  [(Any) <Object>]: This indicates any property can be added to this object.
  [RedirectUri <String[]>]: Specifies the URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent.

TOKENISSUANCEPOLICY <IMicrosoftGraphTokenIssuancePolicy[]>: .
  [AppliesTo <IMicrosoftGraphDirectoryObject[]>]: 
    [DeletedDateTime <DateTime?>]: 
  [Definition <String[]>]: A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.
  [IsOrganizationDefault <Boolean?>]: If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.
  [Description <String>]: Description for this policy.
  [DisplayName <String>]: Display name for this policy.
  [DeletedDateTime <DateTime?>]: 

TOKENLIFETIMEPOLICY <IMicrosoftGraphTokenLifetimePolicy[]>: The tokenLifetimePolicies assigned to this application. Supports $expand.
  [AppliesTo <IMicrosoftGraphDirectoryObject[]>]: 
    [DeletedDateTime <DateTime?>]: 
  [Definition <String[]>]: A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.
  [IsOrganizationDefault <Boolean?>]: If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.
  [Description <String>]: Description for this policy.
  [DisplayName <String>]: Display name for this policy.
  [DeletedDateTime <DateTime?>]: 

WEB <IMicrosoftGraphWebApplication>: webApplication
  [(Any) <Object>]: This indicates any property can be added to this object.
  [HomePageUrl <String>]: Home page or landing page of the application.
  [ImplicitGrantSetting <IMicrosoftGraphImplicitGrantSettings>]: implicitGrantSettings
    [(Any) <Object>]: This indicates any property can be added to this object.
    [EnableAccessTokenIssuance <Boolean?>]: Specifies whether this web application can request an access token using the OAuth 2.0 implicit flow.
    [EnableIdTokenIssuance <Boolean?>]: Specifies whether this web application can request an ID token using the OAuth 2.0 implicit flow.
  [LogoutUrl <String>]: Specifies the URL that will be used by Microsoft's authorization service to logout an user using front-channel, back-channel or SAML logout protocols.
  [RedirectUri <String[]>]: Specifies the URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent.
.Link
https://learn.microsoft.com/powershell/module/az.resources/new-azadapplication
#>
function New-AzADApplication {
  [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphApplication])]
  [CmdletBinding(DefaultParameterSetName = 'ApplicationWithoutCredentialParameterSet', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # The display name for the application.
    # Supports $filter (eq, ne, NOT, ge, le, in, startsWith), $search, and $orderBy.
    ${DisplayName},

    [Parameter(HelpMessage = "The value specifying whether the application is a single tenant or a multi-tenant. Is equivalent to '-SignInAudience AzureADMultipleOrgs' when switch is on")]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.Boolean]
    ${AvailableToOtherTenants},

    [Parameter(HelpMessage = "The URL to the application homepage.")]
    [Alias('WebHomePageUrl')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # home page url for web
    ${HomePage},

    [Parameter(HelpMessage = "The application reply Urls.")]
    [Alias('WebRedirectUri')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String[]]
    ${ReplyUrls},

    [Parameter(HelpMessage = "The URIs that identify the application.")]
    [Alias('IdentifierUris')]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String[]]
    # The URIs that identify the application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant.
    # For more information, see Application Objects and Service Principal Objects.
    # The any operator is required for filter expressions on multi-valued properties.
    # Not nullable.
    # Supports $filter (eq, ne, ge, le, startsWith).
    ${IdentifierUri},

    [Parameter(ParameterSetName = 'ApplicationWithKeyCredentialParameterSet', Mandatory, HelpMessage = "key credentials associated with the application.")]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphKeyCredential[]]
    # The collection of key credentials associated with the application.
    # Not nullable.
    # Supports $filter (eq, NOT, ge, le).
    # To construct, see NOTES section for KEYCREDENTIALS properties and create a hash table.
    ${KeyCredentials},

    [Parameter(ParameterSetName = 'ApplicationWithPasswordCredentialParameterSet', Mandatory, HelpMessage = "Password credentials associated with the application.")]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphPasswordCredential[]]
    # The collection of password credentials associated with the application.
    # Not nullable.
    # To construct, see NOTES section for PASSWORDCREDENTIALS properties and create a hash table.
    ${PasswordCredentials},

    [Parameter(ParameterSetName = 'ApplicationWithKeyPlainParameterSet', Mandatory, HelpMessage = "The value of the 'asymmetric' credential type. It represents the base 64 encoded certificate.")]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    ${CertValue},

    [Parameter(ParameterSetName = 'ApplicationWithPasswordPlainParameterSet', HelpMessage = "The effective start date of the credential usage. The default start date value is today. For an 'asymmetric' type credential, this must be set to on or after the date that the X509 certificate is valid from.")]
    [Parameter(ParameterSetName = 'ApplicationWithKeyPlainParameterSet', HelpMessage = "The effective start date of the credential usage. The default start date value is today. For an 'asymmetric' type credential, this must be set to on or after the date that the X509 certificate is valid from.")]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.DateTime]
    ${StartDate},

    [Parameter(ParameterSetName = 'ApplicationWithPasswordPlainParameterSet', HelpMessage = "The effective end date of the credential usage. The default end date value is one year from today. For an 'asymmetric' type credential, this must be set to on or before the date that the X509 certificate is valid.")]
    [Parameter(ParameterSetName = 'ApplicationWithKeyPlainParameterSet', HelpMessage = "The effective end date of the credential usage. The default end date value is one year from today. For an 'asymmetric' type credential, this must be set to on or before the date that the X509 certificate is valid.")]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.DateTime]
    ${EndDate},

    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphWebApplication]
    # webApplication
    # To construct, see NOTES section for WEB properties and create a hash table.
    ${Web},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphAddIn[]]
    # Defines custom behavior that a consuming service can use to call an app in specific contexts.
    # For example, applications that can render file streams may set the addIns property for its 'FileHandler' functionality.
    # This will let services like Office 365 call the application in the context of a document the user is working on.
    # To construct, see NOTES section for ADDIN properties and create a hash table.
    ${AddIn},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphApiApplication]
    # apiApplication
    # To construct, see NOTES section for API properties and create a hash table.
    ${Api},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphAppRole[]]
    # The collection of roles assigned to the application.
    # With app role assignments, these roles can be assigned to users, groups, or service principals associated with other applications.
    # Not nullable.
    # To construct, see NOTES section for APPROLE properties and create a hash table.
    ${AppRole},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # Unique identifier of the applicationTemplate.
    ${ApplicationTemplateId},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.DateTime]
    # .
    ${CreatedOnBehalfOfDeletedDateTime},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.DateTime]
    # .
    ${DeletedDateTime},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # An optional description of the application.
    # Returned by default.
    # Supports $filter (eq, ne, NOT, ge, le, startsWith) and $search.
    ${Description},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # Specifies whether Microsoft has disabled the registered application.
    # Possible values are: null (default value), NotDisabled, and DisabledDueToViolationOfServicesAgreement (reasons may include suspicious, abusive, or malicious activity, or a violation of the Microsoft Services Agreement).
    # Supports $filter (eq, ne, NOT).
    ${DisabledByMicrosoftStatus},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # Configures the groups claim issued in a user or OAuth 2.0 access token that the application expects.
    # To set this attribute, use one of the following string values: None, SecurityGroup (for security groups and Azure AD roles), All (this gets all security groups, distribution groups, and Azure AD directory roles that the signed-in user is a member of).
    ${GroupMembershipClaim},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphHomeRealmDiscoveryPolicy[]]
    # .
    # To construct, see NOTES section for HOMEREALMDISCOVERYPOLICY properties and create a hash table.
    ${HomeRealmDiscoveryPolicy},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphInformationalUrl]
    # informationalUrl
    # To construct, see NOTES section for INFO properties and create a hash table.
    ${Info},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.Management.Automation.SwitchParameter]
    # Specifies whether this application supports device authentication without a user.
    # The default is false.
    ${IsDeviceOnlyAuthSupported},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.Management.Automation.SwitchParameter]
    # Specifies the fallback application type as public client, such as an installed application running on a mobile device.
    # The default value is false which means the fallback application type is confidential client such as a web app.
    # There are certain scenarios where Azure AD cannot determine the client application type.
    # For example, the ROPC flow where the application is configured without specifying a redirect URI.
    # In those cases Azure AD interprets the application type based on the value of this property.
    ${IsFallbackPublicClient},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # Input File for Logo (The main logo for the application.
    # Not nullable.)
    ${LogoInputFile},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # Notes relevant for the management of the application.
    ${Note},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.Management.Automation.SwitchParameter]
    # .
    ${Oauth2RequirePostResponse},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphOptionalClaims]
    # optionalClaims
    # To construct, see NOTES section for OPTIONALCLAIM properties and create a hash table.
    ${OptionalClaim},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphParentalControlSettings]
    # parentalControlSettings
    # To construct, see NOTES section for PARENTALCONTROLSETTING properties and create a hash table.
    ${ParentalControlSetting},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String[]]
    ${PublicClientRedirectUri},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.Int32]
    ${RequestedAccessTokenVersion},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphRequiredResourceAccess[]]
    # Specifies the resources that the application needs to access.
    # This property also specifies the set of OAuth permission scopes and application roles that it needs for each of those resources.
    # This configuration of access to the required resources drives the consent experience.
    # Not nullable.
    # Supports $filter (eq, NOT, ge, le).
    # To construct, see NOTES section for REQUIREDRESOURCEACCESS properties and create a hash table.
    ${RequiredResourceAccess},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # References application or service contact information from a Service or Asset Management database.
    # Nullable.
    ${ServiceManagementReference},
    
    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [ValidateSet('AzureADMyOrg', 'AzureADMultipleOrgs', 'AzureADandPersonalMicrosoftAccount', 'PersonalMicrosoftAccount')]
    [System.String]
    # Specifies the Microsoft accounts that are supported for the current application.
    # Supported values are: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount.
    # See more in the table below.
    # Supports $filter (eq, ne, NOT).
    ${SignInAudience},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String[]]
    ${SPARedirectUri},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String[]]
    # Custom strings that can be used to categorize and identify the application.
    # Not nullable.Supports $filter (eq, NOT, ge, le, startsWith).
    ${Tag},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [System.String]
    # Specifies the keyId of a public key from the keyCredentials collection.
    # When configured, Azure AD encrypts all the tokens it emits by using the key this property points to.
    # The application code that receives the encrypted token must use the matching private key to decrypt the token before it can be used for the signed-in user.
    ${TokenEncryptionKeyId},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphTokenIssuancePolicy[]]
    # .
    # To construct, see NOTES section for TOKENISSUANCEPOLICY properties and create a hash table.
    ${TokenIssuancePolicy},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphTokenLifetimePolicy[]]
    # The tokenLifetimePolicies assigned to this application.
    # Supports $expand.
    # To construct, see NOTES section for TOKENLIFETIMEPOLICY properties and create a hash table.
    ${TokenLifetimePolicy},

    [Parameter()]
    [Alias("AzContext", "AzureRmContext", "AzureCredential")]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Azure')]
    [System.Management.Automation.PSObject]
    # The credentials, account, tenant, and subscription used for communication with Azure.
    ${DefaultProfile},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
  )

  process {
    if ($PSBoundParameters.ContainsKey('AvailableToOtherTenants')) {
      if ($PSBoundParameters['SignInAudience']) {
        if (($PSBoundParameters['SignInAudience'] -in 'AzureADMyOrg', 'PersonalMicrosoftAccount') -and $PSBoundParameters['AvailableToOtherTenants']) {
          Write-Error "sign in audience '$($PSBoundParameters['SignInAudience'])' cannot be available to other tenants"
          return
        } elseif (($PSBoundParameters['SignInAudience'] -in 'AzureADMultipleOrgs', 'AzureADandPersonalMicrosoftAccount') -and !$PSBoundParameters['AvailableToOtherTenants']) {
          Write-Error "sign in audience '$($PSBoundParameters['SignInAudience'])' is available to other tenants, please try to use 'AzureADMyOrg' or 'PersonalMicrosoftAccount'"
          return
        }  
      } else {
        if ($PSBoundParameters['AvailableToOtherTenants']) {
          $PSBoundParameters['SignInAudience'] = 'AzureADMultipleOrgs'
        } else {
          $PSBoundParameters['SignInAudience'] = 'AzureADMyOrg'
        }
      }
      $null = $PSBoundParameters.Remove('AvailableToOtherTenants')
    } elseif (!$PSBoundParameters['SignInAudience']) {
      $PSBoundParameters['SignInAudience'] = 'AzureADMyOrg'
    }
    # even if payload contains all three redirect options, only one will be added in the actual app, the order is
    # web -> spa -> public client
    if ($PSBoundParameters['HomePage'] -or $PSBoundParameters['ReplyUrls']) {
      if (!$PSBoundParameters['Web']) {
        $PSBoundParameters['Web'] = New-Object -TypeName "Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.MicrosoftGraphWebApplication" -Property $props
      } 

      if ($PSBoundParameters['HomePage']) {
        $PSBoundParameters['Web'].HomePageUrl = $PSBoundParameters['HomePage']
        $null = $PSBoundParameters.Remove('HomePage')
      }
      if ($PSBoundParameters['ReplyUrls']) {
        $PSBoundParameters['Web'].RedirectUri = $PSBoundParameters['ReplyUrls']
        $null = $PSBoundParameters.Remove('ReplyUrls')
      }
      if ($PSBoundParameters['SPARedirectUri']) {
        $null = $PSBoundParameters.Remove('SPARedirectUri')
      }
      if ($PSBoundParameters['PublicClientRedirectUri']) {
        $null = $PSBoundParameters.Remove('PublicClientRedirectUri')
      }
    }
    elseif ($PSBoundParameters['SPARedirectUri']) {
      $PSBoundParameters['SPA'] = New-Object -TypeName "Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.MicrosoftGraphSPAApplication" -Property @{'RedirectUri' = $PSBoundParameters['SPARedirectUri'] }
      $null = $PSBoundParameters.Remove('SPARedirectUri')
      if ($PSBoundParameters['PublicClientRedirectUri']) {
        $null = $PSBoundParameters.Remove('PublicClientRedirectUri')
      }
    }
    elseif ($PSBoundParameters['PublicClientRedirectUri']) {
      $PSBoundParameters['PublicClient'] = New-Object -TypeName "Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.MicrosoftGraphPublicClientApplication" -Property @{'RedirectUri' = $PSBoundParameters['PublicClientRedirectUri'] }
      $null = $PSBoundParameters.Remove('PublicClientRedirectUri')
    }

    if ($PSBoundParameters['RequestedAccessTokenVersion'] -and $PSBoundParameters['Api']) {
      $PSBoundParameters['Api'].RequestedAccessTokenVersion = $PSBoundParameters['RequestedAccessTokenVersion']
    }
    elseif ($PSBoundParameters['RequestedAccessTokenVersion']) {
      $PSBoundParameters['Api'] = New-Object -TypeName "Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.MicrosoftGraphApiApplication" -Property @{'RequestedAccessTokenVersion' = $PSBoundParameters['RequestedAccessTokenVersion'] }
    }
    $null = $PSBoundParameters.Remove('RequestedAccessTokenVersion')

    if ($PSBoundParameters['StartDate']) {
      $sd = $PSBoundParameters['StartDate']
      $null = $PSBoundParameters.Remove('StartDate')
    }
    if ($PSBoundParameters['EndDate']) {
      $ed = $PSBoundParameters['EndDate']
      $null = $PSBoundParameters.Remove('EndDate')
    }

    switch ($PSCmdlet.ParameterSetName) {
      'ApplicationWithPasswordCredentialParameterSet' {
        $pc = $PSBoundParameters['PasswordCredentials']
        $null = $PSBoundParameters.Remove('PasswordCredentials')
        break
      }
      'ApplicationWithKeyPlainParameterSet' {
        $kc = New-Object -TypeName "Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.MicrosoftGraphKeyCredential" `
                                         -Property @{'Key' = ([System.Convert]::FromBase64String($PSBoundParameters['CertValue']));
                                            'Usage'       = 'Verify'; 
                                            'Type'        = 'AsymmetricX509Cert'
                                         }
        $null = $PSBoundParameters.Remove('CertValue')
        $kc.StartDateTime = $sd
        $kc.EndDateTime = $ed
        $PSBoundParameters['KeyCredentials'] = $kc
        break
      }
      default {
        break
      }
    }

    $app = Az.MSGraph.internal\New-AzADApplication @PSBoundParameters
    $param = @{'ObjectId' = $app.Id}

    switch ($PSCmdlet.ParameterSetName) {
      'ApplicationWithPasswordPlainParameterSet' {
        if ($sd) {
          $param['StartDate'] = $sd
        }
        if ($ed) {
          $param['EndDate'] = $ed
        }
        $app.PasswordCredentials = New-AzADAppCredential @param
        break
      }
      'ApplicationWithPasswordCredentialParameterSet' {
        $param['PasswordCredentials'] = $pc
        $app.PasswordCredentials = New-AzADAppCredential @param
        break
      }
      default {
        break
      }
    }

    $PSCmdlet.WriteObject($app)
  }
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDM8T9MDMzXBQff
# xz1F17WeMg7r9WAQBe+qfizkGh70qaCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEID+JAarW65YNyiv0W4QrmIQl
# DNUPaIMgcFQvH+eOTbXZMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAH2OjwxEfqHrbm/GFgf1crO4XL97Xl3pATxxWNOjSEGXkaw1DcX4QkXXb
# WqghUUyKIAyEtqhehxgjlv00agAoTC6C4zxXV2nYSZhnf4weRT6QnczKc0DroorT
# XY2pQ6w8HMoiWgti10n3GNJYzdOUCdRu52NkAYv+lxeHKSvIdzTE94pt3ZdTID85
# pTaFoyph7zvtWoY5b9LoGL26/lP/irsJZ8IzQyohbhn8c0qOHjeecgG9elP7WLIb
# PdeNxjcu3/KkAsMnqYoUSfAhTI/vnjgf2hegU/xS/2a6vk0MA83K/MGOmPArxMrB
# PjHQ2mn8g4eJzDl8yHolYuSQlnyX06GCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDdri737iG8jS4PgLS4Em/uLDB5fUivDZjlOZzkjRvAdQIGaErepzGf
# GBMyMDI1MDYyNTA3MzIyNi41ODVaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAgh4nVhdksfZUgABAAACCDANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTNaFw0yNjA0MjIxOTQyNTNaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQC1y3AI5lIz3Ip1nK5BMUUbGRsjSnCz/VGs33zvY0Ne
# shsPgfld3/Z3/3dS8WKBLlDlosmXJOZlFSiNXUd6DTJxA9ik/ZbCdWJ78LKjbN3t
# FkX2c6RRpRMpA8sq/oBbRryP3c8Q/gxpJAKHHz8cuSn7ewfCLznNmxqliTk3Q5LH
# qz2PjeYKD/dbKMBT2TAAWAvum4z/HXIJ6tFdGoNV4WURZswCSt6ROwaqQ1oAYGvE
# ndH+DXZq1+bHsgvcPNCdTSIpWobQiJS/UKLiR02KNCqB4I9yajFTSlnMIEMz/Ni5
# 38oGI64phcvNpUe2+qaKWHZ8d4T1KghvRmSSF4YF5DNEJbxaCUwsy7nULmsFnTaO
# jVOoTFWWfWXvBuOKkBcQKWGKvrki976j4x+5ezAP36fq3u6dHRJTLZAu4dEuOooU
# 3+kMZr+RBYWjTHQCKV+yZ1ST0eGkbHXoA2lyyRDlNjBQcoeZIxWCZts/d3+nf1ji
# SLN6f6wdHaUz0ADwOTQ/aEo1IC85eFePvyIKaxFJkGU2Mqa6Xzq3qCq5tokIHtjh
# ogsrEgfDKTeFXTtdhl1IPtLcCfMcWOGGAXosVUU7G948F6W96424f2VHD8L3FoyA
# I9+r4zyIQUmqiESzuQWeWpTTjFYwCmgXaGOuSDV8cNOVQB6IPzPneZhVTjwxbAZl
# aQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFKMx4vfOqcUTgYOVB9f18/mhegFNMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBRszKJKwAfswqdaQPFiaYB/ZNAYWDa040X
# TcQsCaCua5nsG1IslYaSpH7miTLr6eQEqXczZoqeOa/xvDnMGifGNda0CHbQwtpn
# IhsutrKO2jhjEaGwlJgOMql21r7Ik6XnBza0e3hBOu4UBkMl/LEX+AURt7i7+RTN
# sGN0cXPwPSbTFE+9z7WagGbY9pwUo/NxkGJseqGCQ/9K2VMU74bw5e7+8IGUhM2x
# spJPqnSeHPhYmcB0WclOxcVIfj/ZuQvworPbTEEYDVCzSN37c0yChPMY7FJ+HGFB
# NJxwd5lKIr7GYfq8a0gOiC2ljGYlc4rt4cCed1XKg83f0l9aUVimWBYXtfNebhpf
# r6Lc3jD8NgsrDhzt0WgnIdnTZCi7jxjsIBilH99pY5/h6bQcLKK/E6KCP9E1YN78
# fLaOXkXMyO6xLrvQZ+uCSi1hdTufFC7oSB/CU5RbfIVHXG0j1o2n1tne4eCbNfKq
# UPTE31tNbWBR23Yiy0r3kQmHeYE1GLbL4pwknqaip1BRn6WIUMJtgncawEN33f8A
# YGZ4a3NnHopzGVV6neffGVag4Tduy+oy1YF+shChoXdMqfhPWFpHe3uJGT4GJEiN
# s4+28a/wHUuF+aRaR0cN5P7XlOwU1360iUCJtQdvKQaNAwGI29KOwS3QGriR9F2j
# OGPUAlpeEzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkEwMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCN
# kvu0NKcSjdYKyrhJZcsyXOUTNKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7AXWyDAiGA8yMDI1MDYyNTAyMDA0
# MFoYDzIwMjUwNjI2MDIwMDQwWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDsBdbI
# AgEAMAcCAQACAjpeMAcCAQACAhLnMAoCBQDsByhIAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBABWwQ4rNL7jHXR3ZfhNJGGpPUHMZyvnQSWnqFifod08otOFb
# dJyeVw732BxsSBZDBigCGNf7J94MgbQ3dqCsX5S8j5NSrxAi0u/PyCQQ6RoSCzkJ
# hIuS5CC8KUWJQYBdxx1MAWSeBdx472vFjKSlUxihmAQpvAtUeCduvN2KJ646cRof
# ObHb1YSU8+yRvowU17JcaV9FDwCeO06RGkhccllnQDthFbpMLbsdzFQt6LsWUOzF
# CvUfmHJpQ864t3ryZxd9I7UusmB9yG0X8LrKPhiZND7wK1I+Z+KkxaL0VqnokXk7
# yNLSWDxOApgobIJKosjO0LyYYhLGKsqG1OIsWGExggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgh4nVhdksfZUgABAAACCDAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCBab2GRxxZdgEKQY4+mAxUVUt+6q5PM9EPdIvYqdGDovTCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EII//jm8JHa2W1O9778t9+Ft2Z5Nm
# KqttPk6Q+9RRpmepMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAIIeJ1YXZLH2VIAAQAAAggwIgQg+VOCvwyPq/K2feMtMQliEVIlRvAS
# ldhrddSmLvO83ekwDQYJKoZIhvcNAQELBQAEggIAYEDsU66YgTeOrbyDeWl2qEw8
# umdtEPUUaaB+Udbd6gOhxZO5pr093g8usxSCWCJ29KeEMm21iTegMRW720bKM6GN
# sn7frVWyFpRqD1Wj3ye6un6WUXKvbUePew6C7SZa6ldsC5kqdIPMpTJrZo1zLDqJ
# A1+SMlmYSnwXclv2yKkRgmkIiEQ1xXOzX2tnt0Ag+ia5WH0jC58AVrLjKPOyuC1j
# +HKFqYRAt37CDAW8hTZx4oEP30dMekq02akgg4M5UlRbxD59frxgj3glr5i4K2RC
# kshU60tzkwYMbUh2jPKBKqw3Vyj1oM5+1dvq7ja3jBQajHzGlAEyvmljVVJeQGY2
# 5l1AqazYzC0nawsVHe+voc59y0/Q4vyHCFURkPKD9hofpxFMUlumTvFmD5wU7pJF
# UPRLtPqj3BzPcyBK1YNsqFAmKwCjdmQ7eiYZqNl3+qknK6NAOqhB0XEUlNlGnoYR
# cb0+eJ7chqvdYvxNphO9RZZsd96pnwuWMnqI/0vvKb0SvnczBeuxLDCseIe0OjR1
# zsD9ESFG1oS9yHaHNzPG2SojIxU26mM8G2hWDuBeIH79do8BSS1SLbpDc8J87s1z
# OcBMaJr7Qnllvk4ILV9PTO1WwY0IlPXCvGolWud0cxjfk0y1MkAERAZQpaj7yT0M
# PB4oHLNkFzd8jw0FqII=
# SIG # End signature block
