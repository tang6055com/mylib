package Lasso;
use strict;
use warnings;

require XSLoader;
XSLoader::load('Lasso');
package Lasso::Identity;
our @ISA = qw(Lasso::Node);

package Lasso::Session;
our @ISA = qw(Lasso::Node);

package Lasso::Federation;
our @ISA = qw(Lasso::Node);

package Lasso::Profile;
our @ISA = qw(Lasso::Node);

package Lasso::Ecp;
our @ISA = qw(Lasso::Profile);

package Lasso::AssertionQuery;
our @ISA = qw(Lasso::Profile);

package Lasso::NameIdManagement;
our @ISA = qw(Lasso::Profile);

package Lasso::Logout;
our @ISA = qw(Lasso::Profile);

package Lasso::Login;
our @ISA = qw(Lasso::Profile);

package Lasso::NameIdentifierMapping;
our @ISA = qw(Lasso::Profile);

package Lasso::NameRegistration;
our @ISA = qw(Lasso::Profile);

package Lasso::Provider;
our @ISA = qw(Lasso::Node);

package Lasso::Server;
our @ISA = qw(Lasso::Provider);

package Lasso::Lecp;
our @ISA = qw(Lasso::Login);

package Lasso::Defederation;
our @ISA = qw(Lasso::Profile);

package Lasso::MiscTextNode;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAuthorityBinding;
our @ISA = qw(Lasso::Node);

package Lasso::SamlNameIdentifier;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAttributeDesignator;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAttribute;
our @ISA = qw(Lasso::SamlAttributeDesignator);

package Lasso::DsRsaKeyValue;
our @ISA = qw(Lasso::Node);

package Lasso::LibAuthnResponseEnvelope;
our @ISA = qw(Lasso::Node);

package Lasso::SamlSubject;
our @ISA = qw(Lasso::Node);

package Lasso::LibSubject;
our @ISA = qw(Lasso::SamlSubject);

package Lasso::SamlAttributeValue;
our @ISA = qw(Lasso::Node);

package Lasso::SamlStatementAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::SamlSubjectStatementAbstract;
our @ISA = qw(Lasso::SamlStatementAbstract);

package Lasso::SamlAttributeStatement;
our @ISA = qw(Lasso::SamlSubjectStatementAbstract);

package Lasso::DsKeyValue;
our @ISA = qw(Lasso::Node);

package Lasso::DsKeyInfo;
our @ISA = qw(Lasso::Node);

package Lasso::LibIDPEntry;
our @ISA = qw(Lasso::Node);

package Lasso::SamlpStatusCode;
our @ISA = qw(Lasso::Node);

package Lasso::SamlpRequestAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::LibNameIdentifierMappingRequest;
our @ISA = qw(Lasso::SamlpRequestAbstract);

package Lasso::LibFederationTerminationNotification;
our @ISA = qw(Lasso::SamlpRequestAbstract);

package Lasso::LibRegisterNameIdentifierRequest;
our @ISA = qw(Lasso::SamlpRequestAbstract);

package Lasso::LibAuthnRequest;
our @ISA = qw(Lasso::SamlpRequestAbstract);

package Lasso::LibAuthnContext;
our @ISA = qw(Lasso::Node);

package Lasso::LibScoping;
our @ISA = qw(Lasso::Node);

package Lasso::LibIDPEntries;
our @ISA = qw(Lasso::Node);

package Lasso::LibLogoutRequest;
our @ISA = qw(Lasso::SamlpRequestAbstract);

package Lasso::LibIDPList;
our @ISA = qw(Lasso::Node);

package Lasso::SamlConditionAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAudienceRestrictionCondition;
our @ISA = qw(Lasso::SamlConditionAbstract);

package Lasso::LibAuthnRequestEnvelope;
our @ISA = qw(Lasso::Node);

package Lasso::LibRequestAuthnContext;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAdvice;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAssertion;
our @ISA = qw(Lasso::Node);

package Lasso::LibAssertion;
our @ISA = qw(Lasso::SamlAssertion);

package Lasso::SamlConditions;
our @ISA = qw(Lasso::Node);

package Lasso::SamlSubjectStatement;
our @ISA = qw(Lasso::SamlSubjectStatementAbstract);

package Lasso::SamlpRequest;
our @ISA = qw(Lasso::SamlpRequestAbstract);

package Lasso::SamlSubjectConfirmation;
our @ISA = qw(Lasso::Node);

package Lasso::SamlpStatus;
our @ISA = qw(Lasso::Node);

package Lasso::SamlAuthenticationStatement;
our @ISA = qw(Lasso::SamlSubjectStatementAbstract);

package Lasso::LibAuthenticationStatement;
our @ISA = qw(Lasso::SamlAuthenticationStatement);

package Lasso::SamlSubjectLocality;
our @ISA = qw(Lasso::Node);

package Lasso::SamlpResponseAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::LibNameIdentifierMappingResponse;
our @ISA = qw(Lasso::SamlpResponseAbstract);

package Lasso::SamlpResponse;
our @ISA = qw(Lasso::SamlpResponseAbstract);

package Lasso::LibStatusResponse;
our @ISA = qw(Lasso::SamlpResponseAbstract);

package Lasso::LibLogoutResponse;
our @ISA = qw(Lasso::LibStatusResponse);

package Lasso::LibRegisterNameIdentifierResponse;
our @ISA = qw(Lasso::LibStatusResponse);

package Lasso::LibAuthnResponse;
our @ISA = qw(Lasso::SamlpResponse);

package Lasso::Samlp2RequestAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2AssertionIDRequest;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Saml2SubjectConfirmationData;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2SubjectLocality;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2ConditionAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2NameIDPolicy;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2Subject;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2Scoping;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2LogoutRequest;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Saml2BaseIDAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2IDPEntry;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2AudienceRestriction;
our @ISA = qw(Lasso::Saml2ConditionAbstract);

package Lasso::Saml2AuthnContext;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2IDPList;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2ProxyRestriction;
our @ISA = qw(Lasso::Saml2ConditionAbstract);

package Lasso::Samlp2SubjectQueryAbstract;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Samlp2AttributeQuery;
our @ISA = qw(Lasso::Samlp2SubjectQueryAbstract);

package Lasso::Samlp2ManageNameIDRequest;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Samlp2Extensions;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2StatusResponse;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2ManageNameIDResponse;
our @ISA = qw(Lasso::Samlp2StatusResponse);

package Lasso::Samlp2ArtifactResponse;
our @ISA = qw(Lasso::Samlp2StatusResponse);

package Lasso::Saml2Attribute;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2Status;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2SubjectConfirmation;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2Terminate;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2Evidence;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2Advice;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2Response;
our @ISA = qw(Lasso::Samlp2StatusResponse);

package Lasso::Samlp2AuthnRequest;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Saml2Assertion;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2NameIDMappingRequest;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Samlp2AuthnQuery;
our @ISA = qw(Lasso::Samlp2SubjectQueryAbstract);

package Lasso::Samlp2LogoutResponse;
our @ISA = qw(Lasso::Samlp2StatusResponse);

package Lasso::Samlp2StatusCode;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2EncryptedElement;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2AuthzDecisionQuery;
our @ISA = qw(Lasso::Samlp2SubjectQueryAbstract);

package Lasso::Saml2StatementAbstract;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2AttributeStatement;
our @ISA = qw(Lasso::Saml2StatementAbstract);

package Lasso::Saml2AuthnStatement;
our @ISA = qw(Lasso::Saml2StatementAbstract);

package Lasso::Saml2AuthzDecisionStatement;
our @ISA = qw(Lasso::Saml2StatementAbstract);

package Lasso::Saml2AttributeValue;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2Action;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2OneTimeUse;
our @ISA = qw(Lasso::Saml2ConditionAbstract);

package Lasso::Saml2NameID;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2KeyInfoConfirmationData;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2StatusDetail;
our @ISA = qw(Lasso::Node);

package Lasso::Samlp2ArtifactResolve;
our @ISA = qw(Lasso::Samlp2RequestAbstract);

package Lasso::Samlp2NameIDMappingResponse;
our @ISA = qw(Lasso::Samlp2StatusResponse);

package Lasso::Samlp2RequestedAuthnContext;
our @ISA = qw(Lasso::Node);

package Lasso::Saml2Conditions;
our @ISA = qw(Lasso::Node);

package Lasso::SoapEnvelope;
our @ISA = qw(Lasso::Node);

package Lasso::SoapBody;
our @ISA = qw(Lasso::Node);

package Lasso::SoapHeader;
our @ISA = qw(Lasso::Node);

package Lasso::SoapFault;
our @ISA = qw(Lasso::Node);

package Lasso::SoapDetail;
our @ISA = qw(Lasso::Node);

