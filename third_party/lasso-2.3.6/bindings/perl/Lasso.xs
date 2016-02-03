
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>

#if defined(__GNUC__)
#  define lasso_log(level, filename, line, function, format, args...)         g_log("Lasso", level, "%s:%i:%s" format, filename, line, function, ##args)
#elif defined(HAVE_VARIADIC_MACROS)
#  define lasso_log(level, format, line, function, ...)          g_log("Lasso", leve, "%s:%i:%s" format, filename, line, function, __VA_ARGS__)
#else
static inline void lasso_log(GLogLevelFlags level, const char *filename,
    int line, const char *function, const char *format, ...)
{
	va_list ap;
	char s[1024];
	va_start(ap, format);
	g_vsnprintf(s, 1024, format, ap);
	va_end(ap);
    g_log("Lasso", level, "%s:%i:%s %s", filename, line, function, s);
}
#define lasso_log lasso_log
#endif

#include "./gobject_handling.c"
#include "./glist_handling.c"
#include "./ghashtable_handling.c"


#define lasso_assign_simple(a,b) a = b;

typedef char* string_non_null;
typedef char* string_or_null;
typedef GList* GList_string;
typedef GList* GList_gobject;
typedef GList* GList_xmlnode;
typedef const GList* GList_string_const;
typedef const GList* GList_gobject_const;

/* #include "ppport.h" */
#include <lasso/debug.h>
#include <lasso/export.h>
#include <lasso/lasso.h>
#include <lasso/registry.h>
#include <lasso/errors.h>
#include <lasso/utils.h>
#include <lasso/logging.h>
#include <lasso/ctypes.h>
#include <lasso/backward_comp.h>
#include <lasso/saml-2.0/ecp.h>
#include <lasso/saml-2.0/assertion_query.h>
#include <lasso/saml-2.0/profile.h>
#include <lasso/saml-2.0/saml2_helper.h>
#include <lasso/saml-2.0/name_id_management.h>
#include <lasso/saml-2.0/provider.h>
#include <lasso/id-ff/logout.h>
#include <lasso/id-ff/identity.h>
#include <lasso/id-ff/session.h>
#include <lasso/id-ff/federation.h>
#include <lasso/id-ff/login.h>
#include <lasso/id-ff/server.h>
#include <lasso/id-ff/name_identifier_mapping.h>
#include <lasso/id-ff/profile.h>
#include <lasso/id-ff/name_registration.h>
#include <lasso/id-ff/provider.h>
#include <lasso/id-ff/lecp.h>
#include <lasso/id-ff/defederation.h>
#include <lasso/xml/lib_subject.h>
#include <lasso/xml/misc_text_node.h>
#include <lasso/xml/xml_enc.h>
#include <lasso/xml/saml_authority_binding.h>
#include <lasso/xml/lib_name_identifier_mapping_request.h>
#include <lasso/xml/saml_name_identifier.h>
#include <lasso/xml/saml_attribute_statement.h>
#include <lasso/xml/saml_attribute_designator.h>
#include <lasso/xml/saml_attribute.h>
#include <lasso/xml/saml_audience_restriction_condition.h>
#include <lasso/xml/strings.h>
#include <lasso/xml/ds_rsa_key_value.h>
#include <lasso/xml/lib_federation_termination_notification.h>
#include <lasso/xml/lib_register_name_identifier_request.h>
#include <lasso/xml/lib_authentication_statement.h>
#include <lasso/xml/lib_name_identifier_mapping_response.h>
#include <lasso/xml/saml_subject_statement_abstract.h>
#include <lasso/xml/samlp_response.h>
#include <lasso/xml/lib_authn_response_envelope.h>
#include <lasso/xml/saml_subject.h>
#include <lasso/xml/saml_attribute_value.h>
#include <lasso/xml/saml_statement_abstract.h>
#include <lasso/xml/ds_key_value.h>
#include <lasso/xml/ds_key_info.h>
#include <lasso/xml/lib_idp_entry.h>
#include <lasso/xml/samlp_status_code.h>
#include <lasso/xml/samlp_request_abstract.h>
#include <lasso/xml/xml.h>
#include <lasso/xml/tools.h>
#include <lasso/xml/lib_authn_request.h>
#include <lasso/xml/lib_authn_context.h>
#include <lasso/xml/lib_scoping.h>
#include <lasso/xml/lib_idp_entries.h>
#include <lasso/xml/lib_logout_request.h>
#include <lasso/xml/lib_idp_list.h>
#include <lasso/xml/saml_condition_abstract.h>
#include <lasso/xml/lib_authn_request_envelope.h>
#include <lasso/xml/lib_request_authn_context.h>
#include <lasso/xml/saml_advice.h>
#include <lasso/xml/lib_logout_response.h>
#include <lasso/xml/saml_assertion.h>
#include <lasso/xml/lib_assertion.h>
#include <lasso/xml/lib_status_response.h>
#include <lasso/xml/saml_conditions.h>
#include <lasso/xml/saml_subject_statement.h>
#include <lasso/xml/lib_register_name_identifier_response.h>
#include <lasso/xml/samlp_request.h>
#include <lasso/xml/saml_subject_confirmation.h>
#include <lasso/xml/samlp_status.h>
#include <lasso/xml/saml_authentication_statement.h>
#include <lasso/xml/saml_subject_locality.h>
#include <lasso/xml/samlp_response_abstract.h>
#include <lasso/xml/lib_authn_response.h>
#include <lasso/xml/saml-2.0/samlp2_request_abstract.h>
#include <lasso/xml/saml-2.0/samlp2_assertion_id_request.h>
#include <lasso/xml/saml-2.0/saml2_subject_confirmation_data.h>
#include <lasso/xml/saml-2.0/saml2_subject_locality.h>
#include <lasso/xml/saml-2.0/saml2_condition_abstract.h>
#include <lasso/xml/saml-2.0/samlp2_manage_name_id_response.h>
#include <lasso/xml/saml-2.0/samlp2_name_id_policy.h>
#include <lasso/xml/saml-2.0/samlp2_attribute_query.h>
#include <lasso/xml/saml-2.0/saml2_subject.h>
#include <lasso/xml/saml-2.0/samlp2_artifact_response.h>
#include <lasso/xml/saml-2.0/saml2_attribute_statement.h>
#include <lasso/xml/saml-2.0/samlp2_scoping.h>
#include <lasso/xml/saml-2.0/samlp2_logout_request.h>
#include <lasso/xml/saml-2.0/saml2_base_idabstract.h>
#include <lasso/xml/saml-2.0/samlp2_idp_entry.h>
#include <lasso/xml/saml-2.0/saml2_audience_restriction.h>
#include <lasso/xml/saml-2.0/saml2_authn_context.h>
#include <lasso/xml/saml-2.0/samlp2_idp_list.h>
#include <lasso/xml/saml-2.0/saml2_proxy_restriction.h>
#include <lasso/xml/saml-2.0/samlp2_subject_query_abstract.h>
#include <lasso/xml/saml-2.0/samlp2_manage_name_id_request.h>
#include <lasso/xml/saml-2.0/samlp2_extensions.h>
#include <lasso/xml/saml-2.0/samlp2_status_response.h>
#include <lasso/xml/saml-2.0/saml2_attribute.h>
#include <lasso/xml/saml-2.0/samlp2_status.h>
#include <lasso/xml/saml-2.0/saml2_subject_confirmation.h>
#include <lasso/xml/saml-2.0/samlp2_terminate.h>
#include <lasso/xml/saml-2.0/saml2_evidence.h>
#include <lasso/xml/saml-2.0/saml2_authn_statement.h>
#include <lasso/xml/saml-2.0/saml2_advice.h>
#include <lasso/xml/saml-2.0/samlp2_response.h>
#include <lasso/xml/saml-2.0/saml2_authz_decision_statement.h>
#include <lasso/xml/saml-2.0/samlp2_authn_request.h>
#include <lasso/xml/saml-2.0/saml2_assertion.h>
#include <lasso/xml/saml-2.0/samlp2_name_id_mapping_request.h>
#include <lasso/xml/saml-2.0/samlp2_authn_query.h>
#include <lasso/xml/saml-2.0/samlp2_logout_response.h>
#include <lasso/xml/saml-2.0/samlp2_status_code.h>
#include <lasso/xml/saml-2.0/saml2_encrypted_element.h>
#include <lasso/xml/saml-2.0/samlp2_authz_decision_query.h>
#include <lasso/xml/saml-2.0/saml2_statement_abstract.h>
#include <lasso/xml/saml-2.0/saml2_attribute_value.h>
#include <lasso/xml/saml-2.0/saml2_action.h>
#include <lasso/xml/saml-2.0/saml2_one_time_use.h>
#include <lasso/xml/saml-2.0/saml2_name_id.h>
#include <lasso/xml/saml-2.0/saml2_key_info_confirmation_data.h>
#include <lasso/xml/saml-2.0/saml2_strings.h>
#include <lasso/xml/saml-2.0/samlp2_status_detail.h>
#include <lasso/xml/saml-2.0/samlp2_artifact_resolve.h>
#include <lasso/xml/saml-2.0/samlp2_name_id_mapping_response.h>
#include <lasso/xml/saml-2.0/samlp2_requested_authn_context.h>
#include <lasso/xml/saml-2.0/saml2_conditions.h>
#include <lasso/xml/soap-1.1/soap_envelope.h>
#include <lasso/xml/soap-1.1/soap_body.h>
#include <lasso/xml/soap-1.1/soap_header.h>
#include <lasso/xml/soap-1.1/soap_fault.h>
#include <lasso/xml/soap-1.1/soap_detail.h>

MODULE = Lasso PACKAGE = Lasso::Node

INCLUDE: LassoNode.xs

MODULE = Lasso		PACKAGE = Lasso      PREFIX = lasso_ 

PROTOTYPES: ENABLE

BOOT:
{
    SV *ct;
    HV *stash;

    init_perl_lasso();
    stash = gv_stashpv("Lasso::Constants", 1);
    ct = newSViv(LASSO_CHECK_VERSION_EXACT);
    newCONSTSUB(stash, "CHECK_VERSION_EXACT", ct);
    ct = newSViv(LASSO_CHECK_VERSIONABI_COMPATIBLE);
    newCONSTSUB(stash, "CHECK_VERSIONABI_COMPATIBLE", ct);
    ct = newSViv(LASSO_CHECK_VERSION_NUMERIC);
    newCONSTSUB(stash, "CHECK_VERSION_NUMERIC", ct);
    ct = newSViv(LASSO_ERROR_UNDEFINED);
    newCONSTSUB(stash, "ERROR_UNDEFINED", ct);
    ct = newSViv(LASSO_ERROR_UNIMPLEMENTED);
    newCONSTSUB(stash, "ERROR_UNIMPLEMENTED", ct);
    ct = newSViv(LASSO_ERROR_OUT_OF_MEMORY);
    newCONSTSUB(stash, "ERROR_OUT_OF_MEMORY", ct);
    ct = newSViv(LASSO_ERROR_CAST_FAILED);
    newCONSTSUB(stash, "ERROR_CAST_FAILED", ct);
    ct = newSViv(LASSO_XML_ERROR_NODE_NOT_FOUND);
    newCONSTSUB(stash, "XML_ERROR_NODE_NOT_FOUND", ct);
    ct = newSViv(LASSO_XML_ERROR_NODE_CONTENT_NOT_FOUND);
    newCONSTSUB(stash, "XML_ERROR_NODE_CONTENT_NOT_FOUND", ct);
    ct = newSViv(LASSO_XML_ERROR_ATTR_NOT_FOUND);
    newCONSTSUB(stash, "XML_ERROR_ATTR_NOT_FOUND", ct);
    ct = newSViv(LASSO_XML_ERROR_ATTR_VALUE_NOT_FOUND);
    newCONSTSUB(stash, "XML_ERROR_ATTR_VALUE_NOT_FOUND", ct);
    ct = newSViv(LASSO_XML_ERROR_INVALID_FILE);
    newCONSTSUB(stash, "XML_ERROR_INVALID_FILE", ct);
    ct = newSViv(LASSO_XML_ERROR_OBJECT_CONSTRUCTION_FAILED);
    newCONSTSUB(stash, "XML_ERROR_OBJECT_CONSTRUCTION_FAILED", ct);
    ct = newSViv(LASSO_XML_ERROR_MISSING_NAMESPACE);
    newCONSTSUB(stash, "XML_ERROR_MISSING_NAMESPACE", ct);
    ct = newSViv(LASSO_XML_ERROR_SCHEMA_INVALID_FRAGMENT);
    newCONSTSUB(stash, "XML_ERROR_SCHEMA_INVALID_FRAGMENT", ct);
    ct = newSViv(LASSO_DS_ERROR_SIGNATURE_NOT_FOUND);
    newCONSTSUB(stash, "DS_ERROR_SIGNATURE_NOT_FOUND", ct);
    ct = newSViv(LASSO_DS_ERROR_INVALID_SIGNATURE);
    newCONSTSUB(stash, "DS_ERROR_INVALID_SIGNATURE", ct);
    ct = newSViv(LASSO_DS_ERROR_SIGNATURE_TMPL_CREATION_FAILED);
    newCONSTSUB(stash, "DS_ERROR_SIGNATURE_TMPL_CREATION_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_CONTEXT_CREATION_FAILED);
    newCONSTSUB(stash, "DS_ERROR_CONTEXT_CREATION_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_PUBLIC_KEY_LOAD_FAILED);
    newCONSTSUB(stash, "DS_ERROR_PUBLIC_KEY_LOAD_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_PRIVATE_KEY_LOAD_FAILED);
    newCONSTSUB(stash, "DS_ERROR_PRIVATE_KEY_LOAD_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_CERTIFICATE_LOAD_FAILED);
    newCONSTSUB(stash, "DS_ERROR_CERTIFICATE_LOAD_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_SIGNATURE_FAILED);
    newCONSTSUB(stash, "DS_ERROR_SIGNATURE_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_KEYS_MNGR_CREATION_FAILED);
    newCONSTSUB(stash, "DS_ERROR_KEYS_MNGR_CREATION_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_KEYS_MNGR_INIT_FAILED);
    newCONSTSUB(stash, "DS_ERROR_KEYS_MNGR_INIT_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_SIGNATURE_VERIFICATION_FAILED);
    newCONSTSUB(stash, "DS_ERROR_SIGNATURE_VERIFICATION_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_CA_CERT_CHAIN_LOAD_FAILED);
    newCONSTSUB(stash, "DS_ERROR_CA_CERT_CHAIN_LOAD_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_INVALID_SIGALG);
    newCONSTSUB(stash, "DS_ERROR_INVALID_SIGALG", ct);
    ct = newSViv(LASSO_DS_ERROR_DIGEST_COMPUTE_FAILED);
    newCONSTSUB(stash, "DS_ERROR_DIGEST_COMPUTE_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_SIGNATURE_TEMPLATE_NOT_FOUND);
    newCONSTSUB(stash, "DS_ERROR_SIGNATURE_TEMPLATE_NOT_FOUND", ct);
    ct = newSViv(LASSO_DS_ERROR_TOO_MUCH_REFERENCES);
    newCONSTSUB(stash, "DS_ERROR_TOO_MUCH_REFERENCES", ct);
    ct = newSViv(LASSO_DS_ERROR_INVALID_REFERENCE_FOR_SAML);
    newCONSTSUB(stash, "DS_ERROR_INVALID_REFERENCE_FOR_SAML", ct);
    ct = newSViv(LASSO_DS_ERROR_DECRYPTION_FAILED);
    newCONSTSUB(stash, "DS_ERROR_DECRYPTION_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_ENCRYPTION_FAILED);
    newCONSTSUB(stash, "DS_ERROR_ENCRYPTION_FAILED", ct);
    ct = newSViv(LASSO_DS_ERROR_DECRYPTION_FAILED_MISSING_PRIVATE_KEY);
    newCONSTSUB(stash, "DS_ERROR_DECRYPTION_FAILED_MISSING_PRIVATE_KEY", ct);
    ct = newSViv(LASSO_SERVER_ERROR_PROVIDER_NOT_FOUND);
    newCONSTSUB(stash, "SERVER_ERROR_PROVIDER_NOT_FOUND", ct);
    ct = newSViv(LASSO_SERVER_ERROR_ADD_PROVIDER_FAILED);
    newCONSTSUB(stash, "SERVER_ERROR_ADD_PROVIDER_FAILED", ct);
    ct = newSViv(LASSO_SERVER_ERROR_ADD_PROVIDER_PROTOCOL_MISMATCH);
    newCONSTSUB(stash, "SERVER_ERROR_ADD_PROVIDER_PROTOCOL_MISMATCH", ct);
    ct = newSViv(LASSO_SERVER_ERROR_SET_ENCRYPTION_PRIVATE_KEY_FAILED);
    newCONSTSUB(stash, "SERVER_ERROR_SET_ENCRYPTION_PRIVATE_KEY_FAILED", ct);
    ct = newSViv(LASSO_SERVER_ERROR_INVALID_XML);
    newCONSTSUB(stash, "SERVER_ERROR_INVALID_XML", ct);
    ct = newSViv(LASSO_LOGOUT_ERROR_UNSUPPORTED_PROFILE);
    newCONSTSUB(stash, "LOGOUT_ERROR_UNSUPPORTED_PROFILE", ct);
    ct = newSViv(LASSO_LOGOUT_ERROR_REQUEST_DENIED);
    newCONSTSUB(stash, "LOGOUT_ERROR_REQUEST_DENIED", ct);
    ct = newSViv(LASSO_LOGOUT_ERROR_FEDERATION_NOT_FOUND);
    newCONSTSUB(stash, "LOGOUT_ERROR_FEDERATION_NOT_FOUND", ct);
    ct = newSViv(LASSO_LOGOUT_ERROR_UNKNOWN_PRINCIPAL);
    newCONSTSUB(stash, "LOGOUT_ERROR_UNKNOWN_PRINCIPAL", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_QUERY);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_QUERY", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_POST_MSG);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_POST_MSG", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_SOAP_MSG);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_SOAP_MSG", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_REQUEST);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_REQUEST", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_HTTP_METHOD);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_HTTP_METHOD", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_PROTOCOLPROFILE);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_PROTOCOLPROFILE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_MSG);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_MSG", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_REMOTE_PROVIDERID);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_REMOTE_PROVIDERID", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_UNSUPPORTED_PROFILE);
    newCONSTSUB(stash, "PROFILE_ERROR_UNSUPPORTED_PROFILE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_UNKNOWN_PROFILE_URL);
    newCONSTSUB(stash, "PROFILE_ERROR_UNKNOWN_PROFILE_URL", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_IDENTITY_NOT_FOUND);
    newCONSTSUB(stash, "PROFILE_ERROR_IDENTITY_NOT_FOUND", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_FEDERATION_NOT_FOUND);
    newCONSTSUB(stash, "PROFILE_ERROR_FEDERATION_NOT_FOUND", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_NAME_IDENTIFIER_NOT_FOUND);
    newCONSTSUB(stash, "PROFILE_ERROR_NAME_IDENTIFIER_NOT_FOUND", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_BUILDING_QUERY_FAILED);
    newCONSTSUB(stash, "PROFILE_ERROR_BUILDING_QUERY_FAILED", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_BUILDING_REQUEST_FAILED);
    newCONSTSUB(stash, "PROFILE_ERROR_BUILDING_REQUEST_FAILED", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_BUILDING_MESSAGE_FAILED);
    newCONSTSUB(stash, "PROFILE_ERROR_BUILDING_MESSAGE_FAILED", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_BUILDING_RESPONSE_FAILED);
    newCONSTSUB(stash, "PROFILE_ERROR_BUILDING_RESPONSE_FAILED", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_SESSION_NOT_FOUND);
    newCONSTSUB(stash, "PROFILE_ERROR_SESSION_NOT_FOUND", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_BAD_IDENTITY_DUMP);
    newCONSTSUB(stash, "PROFILE_ERROR_BAD_IDENTITY_DUMP", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_BAD_SESSION_DUMP);
    newCONSTSUB(stash, "PROFILE_ERROR_BAD_SESSION_DUMP", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_RESPONSE);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_RESPONSE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_STATUS_CODE);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_STATUS_CODE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_ARTIFACT);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_ARTIFACT", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_RESOURCE_OFFERING);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_RESOURCE_OFFERING", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_SERVICE_DESCRIPTION);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_SERVICE_DESCRIPTION", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_SERVICE_TYPE);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_SERVICE_TYPE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_ASSERTION);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_ASSERTION", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_SUBJECT);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_SUBJECT", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_NAME_IDENTIFIER);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_NAME_IDENTIFIER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_ARTIFACT);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_ARTIFACT", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_ENCRYPTION_PRIVATE_KEY);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_ENCRYPTION_PRIVATE_KEY", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_STATUS_NOT_SUCCESS);
    newCONSTSUB(stash, "PROFILE_ERROR_STATUS_NOT_SUCCESS", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_ISSUER);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_ISSUER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_SERVICE_INSTANCE);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_SERVICE_INSTANCE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_ENDPOINT_REFERENCE);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_ENDPOINT_REFERENCE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_ENDPOINT_REFERENCE_ADDRESS);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_ENDPOINT_REFERENCE_ADDRESS", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_ISSUER);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_ISSUER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_MISSING_SERVER);
    newCONSTSUB(stash, "PROFILE_ERROR_MISSING_SERVER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_UNKNOWN_PROVIDER);
    newCONSTSUB(stash, "PROFILE_ERROR_UNKNOWN_PROVIDER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_CANNOT_VERIFY_SIGNATURE);
    newCONSTSUB(stash, "PROFILE_ERROR_CANNOT_VERIFY_SIGNATURE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_CANNOT_FIND_A_PROVIDER);
    newCONSTSUB(stash, "PROFILE_ERROR_CANNOT_FIND_A_PROVIDER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_RESPONSE_DOES_NOT_MATCH_REQUEST);
    newCONSTSUB(stash, "PROFILE_ERROR_RESPONSE_DOES_NOT_MATCH_REQUEST", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_REQUEST);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_REQUEST", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_RESPONSE);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_RESPONSE", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_UNSUPPORTED_BINDING);
    newCONSTSUB(stash, "PROFILE_ERROR_UNSUPPORTED_BINDING", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_ASSERTION_CONDITIONS);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_ASSERTION_CONDITIONS", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_INVALID_ASSERTION);
    newCONSTSUB(stash, "PROFILE_ERROR_INVALID_ASSERTION", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_UNKNOWN_ISSUER);
    newCONSTSUB(stash, "PROFILE_ERROR_UNKNOWN_ISSUER", ct);
    ct = newSViv(LASSO_PROFILE_ERROR_ISSUER_IS_NOT_AN_IDP);
    newCONSTSUB(stash, "PROFILE_ERROR_ISSUER_IS_NOT_AN_IDP", ct);
    ct = newSViv(LASSO_PARAM_ERROR_BAD_TYPE_OR_NULL_OBJ);
    newCONSTSUB(stash, "PARAM_ERROR_BAD_TYPE_OR_NULL_OBJ", ct);
    ct = newSViv(LASSO_PARAM_ERROR_INVALID_VALUE);
    newCONSTSUB(stash, "PARAM_ERROR_INVALID_VALUE", ct);
    ct = newSViv(LASSO_PARAM_ERROR_CHECK_FAILED);
    newCONSTSUB(stash, "PARAM_ERROR_CHECK_FAILED", ct);
    ct = newSViv(LASSO_PARAM_ERROR_NON_INITIALIZED_OBJECT);
    newCONSTSUB(stash, "PARAM_ERROR_NON_INITIALIZED_OBJECT", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_FEDERATION_NOT_FOUND);
    newCONSTSUB(stash, "LOGIN_ERROR_FEDERATION_NOT_FOUND", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_CONSENT_NOT_OBTAINED);
    newCONSTSUB(stash, "LOGIN_ERROR_CONSENT_NOT_OBTAINED", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_INVALID_NAMEIDPOLICY);
    newCONSTSUB(stash, "LOGIN_ERROR_INVALID_NAMEIDPOLICY", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_REQUEST_DENIED);
    newCONSTSUB(stash, "LOGIN_ERROR_REQUEST_DENIED", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_INVALID_SIGNATURE);
    newCONSTSUB(stash, "LOGIN_ERROR_INVALID_SIGNATURE", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_UNSIGNED_AUTHN_REQUEST);
    newCONSTSUB(stash, "LOGIN_ERROR_UNSIGNED_AUTHN_REQUEST", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_STATUS_NOT_SUCCESS);
    newCONSTSUB(stash, "LOGIN_ERROR_STATUS_NOT_SUCCESS", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_UNKNOWN_PRINCIPAL);
    newCONSTSUB(stash, "LOGIN_ERROR_UNKNOWN_PRINCIPAL", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_NO_DEFAULT_ENDPOINT);
    newCONSTSUB(stash, "LOGIN_ERROR_NO_DEFAULT_ENDPOINT", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_ASSERTION_REPLAY);
    newCONSTSUB(stash, "LOGIN_ERROR_ASSERTION_REPLAY", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_ASSERTION_DOES_NOT_MATCH_REQUEST_ID);
    newCONSTSUB(stash, "LOGIN_ERROR_ASSERTION_DOES_NOT_MATCH_REQUEST_ID", ct);
    ct = newSViv(LASSO_LOGIN_ERROR_INVALID_ASSERTION_SIGNATURE);
    newCONSTSUB(stash, "LOGIN_ERROR_INVALID_ASSERTION_SIGNATURE", ct);
    ct = newSViv(LASSO_DEFEDERATION_ERROR_MISSING_NAME_IDENTIFIER);
    newCONSTSUB(stash, "DEFEDERATION_ERROR_MISSING_NAME_IDENTIFIER", ct);
    ct = newSViv(LASSO_SOAP_ERROR_REDIRECT_REQUEST_FAULT);
    newCONSTSUB(stash, "SOAP_ERROR_REDIRECT_REQUEST_FAULT", ct);
    ct = newSViv(LASSO_SOAP_FAULT_REDIRECT_REQUEST);
    newCONSTSUB(stash, "SOAP_FAULT_REDIRECT_REQUEST", ct);
    ct = newSViv(LASSO_SOAP_ERROR_MISSING_ENVELOPE);
    newCONSTSUB(stash, "SOAP_ERROR_MISSING_ENVELOPE", ct);
    ct = newSViv(LASSO_SOAP_ERROR_MISSING_HEADER);
    newCONSTSUB(stash, "SOAP_ERROR_MISSING_HEADER", ct);
    ct = newSViv(LASSO_SOAP_ERROR_MISSING_BODY);
    newCONSTSUB(stash, "SOAP_ERROR_MISSING_BODY", ct);
    ct = newSViv(LASSO_SOAP_ERROR_MISSING_SOAP_FAULT_DETAIL);
    newCONSTSUB(stash, "SOAP_ERROR_MISSING_SOAP_FAULT_DETAIL", ct);
    ct = newSViv(LASSO_NAME_IDENTIFIER_MAPPING_ERROR_MISSING_TARGET_NAMESPACE);
    newCONSTSUB(stash, "NAME_IDENTIFIER_MAPPING_ERROR_MISSING_TARGET_NAMESPACE", ct);
    ct = newSViv(LASSO_NAME_IDENTIFIER_MAPPING_ERROR_FORBIDDEN_CALL_ON_THIS_SIDE);
    newCONSTSUB(stash, "NAME_IDENTIFIER_MAPPING_ERROR_FORBIDDEN_CALL_ON_THIS_SIDE", ct);
    ct = newSViv(LASSO_NAME_IDENTIFIER_MAPPING_ERROR_MISSING_TARGET_IDENTIFIER);
    newCONSTSUB(stash, "NAME_IDENTIFIER_MAPPING_ERROR_MISSING_TARGET_IDENTIFIER", ct);
    ct = newSViv(LASSO_DATA_SERVICE_ERROR_UNREGISTERED_DST);
    newCONSTSUB(stash, "DATA_SERVICE_ERROR_UNREGISTERED_DST", ct);
    ct = newSViv(LASSO_DATA_SERVICE_ERROR_CANNOT_ADD_ITEM);
    newCONSTSUB(stash, "DATA_SERVICE_ERROR_CANNOT_ADD_ITEM", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_CORRELATION);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_CORRELATION", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_SECURITY);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_SECURITY", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_ASSERTION_ID);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_ASSERTION_ID", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_ENDPOINT);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_ENDPOINT", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_SOAP_FAULT);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_SOAP_FAULT", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_UNSUPPORTED_SECURITY_MECHANISM);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_UNSUPPORTED_SECURITY_MECHANISM", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_DESCRIPTION);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_DESCRIPTION", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_RESOURCE_ID);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_RESOURCE_ID", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_CREDENTIAL_REF);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_CREDENTIAL_REF", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_INVALID_OR_MISSING_REFERENCE_TO_MESSAGE_ID);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_INVALID_OR_MISSING_REFERENCE_TO_MESSAGE_ID", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_SECURITY_MECHANISM_CHECK_FAILED);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_SECURITY_MECHANISM_CHECK_FAILED", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_UNKNOWN_STATUS_CODE);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_UNKNOWN_STATUS_CODE", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_SERVER_INTERACTION_REQUIRED);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_SERVER_INTERACTION_REQUIRED", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_SERVER_INTERACTION_REQUIRED_FOR_DATA);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_SERVER_INTERACTION_REQUIRED_FOR_DATA", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_REDIRECT_REQUEST);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_REDIRECT_REQUEST", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_REDIRECT_REQUEST_UNSUPPORTED_BY_REQUESTER);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_REDIRECT_REQUEST_UNSUPPORTED_BY_REQUESTER", ct);
    ct = newSViv(LASSO_WSF_PROFILE_ERROR_MISSING_SENDER_ID);
    newCONSTSUB(stash, "WSF_PROFILE_ERROR_MISSING_SENDER_ID", ct);
    ct = newSViv(LASSO_DISCOVERY_ERROR_SVC_METADATA_REGISTER_FAILED);
    newCONSTSUB(stash, "DISCOVERY_ERROR_SVC_METADATA_REGISTER_FAILED", ct);
    ct = newSViv(LASSO_DISCOVERY_ERROR_SVC_METADATA_ASSOCIATION_ADD_FAILED);
    newCONSTSUB(stash, "DISCOVERY_ERROR_SVC_METADATA_ASSOCIATION_ADD_FAILED", ct);
    ct = newSViv(LASSO_DISCOVERY_ERROR_MISSING_REQUESTED_SERVICE);
    newCONSTSUB(stash, "DISCOVERY_ERROR_MISSING_REQUESTED_SERVICE", ct);
    ct = newSViv(LASSO_DISCOVERY_ERROR_FAILED_TO_BUILD_ENDPOINT_REFERENCE);
    newCONSTSUB(stash, "DISCOVERY_ERROR_FAILED_TO_BUILD_ENDPOINT_REFERENCE", ct);
    ct = newSViv(LASSO_DST_ERROR_MISSING_SERVICE_DATA);
    newCONSTSUB(stash, "DST_ERROR_MISSING_SERVICE_DATA", ct);
    ct = newSViv(LASSO_DST_ERROR_QUERY_FAILED);
    newCONSTSUB(stash, "DST_ERROR_QUERY_FAILED", ct);
    ct = newSViv(LASSO_DST_ERROR_QUERY_PARTIALLY_FAILED);
    newCONSTSUB(stash, "DST_ERROR_QUERY_PARTIALLY_FAILED", ct);
    ct = newSViv(LASSO_DST_ERROR_MODIFY_FAILED);
    newCONSTSUB(stash, "DST_ERROR_MODIFY_FAILED", ct);
    ct = newSViv(LASSO_DST_ERROR_MODIFY_PARTIALLY_FAILED);
    newCONSTSUB(stash, "DST_ERROR_MODIFY_PARTIALLY_FAILED", ct);
    ct = newSViv(LASSO_DST_ERROR_NEW_DATA_MISSING);
    newCONSTSUB(stash, "DST_ERROR_NEW_DATA_MISSING", ct);
    ct = newSViv(LASSO_DST_ERROR_QUERY_NOT_FOUND);
    newCONSTSUB(stash, "DST_ERROR_QUERY_NOT_FOUND", ct);
    ct = newSViv(LASSO_DST_ERROR_NO_DATA);
    newCONSTSUB(stash, "DST_ERROR_NO_DATA", ct);
    ct = newSViv(LASSO_DST_ERROR_MALFORMED_QUERY);
    newCONSTSUB(stash, "DST_ERROR_MALFORMED_QUERY", ct);
    ct = newSViv(LASSO_DST_ERROR_EMPTY_REQUEST);
    newCONSTSUB(stash, "DST_ERROR_EMPTY_REQUEST", ct);
    ct = newSViv(LASSO_REGISTRY_ERROR_KEY_EXISTS);
    newCONSTSUB(stash, "REGISTRY_ERROR_KEY_EXISTS", ct);
    ct = newSViv(LASSO_PROVIDER_ERROR_MISSING_PUBLIC_KEY);
    newCONSTSUB(stash, "PROVIDER_ERROR_MISSING_PUBLIC_KEY", ct);
    ct = newSViv(LASSO_WSSEC_ERROR_MISSING_SECURITY_TOKEN);
    newCONSTSUB(stash, "WSSEC_ERROR_MISSING_SECURITY_TOKEN", ct);
    ct = newSViv(LASSO_WSSEC_ERROR_BAD_PASSWORD);
    newCONSTSUB(stash, "WSSEC_ERROR_BAD_PASSWORD", ct);
    ct = newSViv(LASSO_IDWSF2_DISCOVERY_ERROR_FAILED);
    newCONSTSUB(stash, "IDWSF2_DISCOVERY_ERROR_FAILED", ct);
    ct = newSViv(LASSO_IDWSF2_DISCOVERY_ERROR_FORBIDDEN);
    newCONSTSUB(stash, "IDWSF2_DISCOVERY_ERROR_FORBIDDEN", ct);
    ct = newSViv(LASSO_IDWSF2_DISCOVERY_ERROR_DUPLICATE);
    newCONSTSUB(stash, "IDWSF2_DISCOVERY_ERROR_DUPLICATE", ct);
    ct = newSViv(LASSO_IDWSF2_DISCOVERY_ERROR_LOGICAL_DUPLICATE);
    newCONSTSUB(stash, "IDWSF2_DISCOVERY_ERROR_LOGICAL_DUPLICATE", ct);
    ct = newSViv(LASSO_IDWSF2_DISCOVERY_ERROR_NO_RESULTS);
    newCONSTSUB(stash, "IDWSF2_DISCOVERY_ERROR_NO_RESULTS", ct);
    ct = newSViv(LASSO_IDWSF2_DISCOVERY_ERROR_NOT_FOUND);
    newCONSTSUB(stash, "IDWSF2_DISCOVERY_ERROR_NOT_FOUND", ct);
    ct = newSViv(LASSO_IDWSF2_DST_ERROR_DUPLICATE_ITEM);
    newCONSTSUB(stash, "IDWSF2_DST_ERROR_DUPLICATE_ITEM", ct);
    ct = newSViv(LASSO_IDWSF2_DST_ERROR_PARTIAL_FAILURE);
    newCONSTSUB(stash, "IDWSF2_DST_ERROR_PARTIAL_FAILURE", ct);
    ct = newSViv(LASSO_IDWSF2_DST_ERROR_UNKNOWN_STATUS_CODE);
    newCONSTSUB(stash, "IDWSF2_DST_ERROR_UNKNOWN_STATUS_CODE", ct);
    ct = newSViv(LASSO_IDWSF2_DST_ERROR_ITEM_NOT_FOUND);
    newCONSTSUB(stash, "IDWSF2_DST_ERROR_ITEM_NOT_FOUND", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_ERROR_ATTRIBUTE_REQUEST_ALREADY_EXIST);
    newCONSTSUB(stash, "ASSERTION_QUERY_ERROR_ATTRIBUTE_REQUEST_ALREADY_EXIST", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_ERROR_NOT_AN_ATTRIBUTE_QUERY);
    newCONSTSUB(stash, "ASSERTION_QUERY_ERROR_NOT_AN_ATTRIBUTE_QUERY", ct);
    ct = newSViv(BACKWARD_COMP_H);
    newCONSTSUB(stash, "RD_COMP_H", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_REQUEST_TYPE_UNSET);
    newCONSTSUB(stash, "ASSERTION_QUERY_REQUEST_TYPE_UNSET", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_REQUEST_TYPE_ASSERTION_ID);
    newCONSTSUB(stash, "ASSERTION_QUERY_REQUEST_TYPE_ASSERTION_ID", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_REQUEST_TYPE_AUTHN);
    newCONSTSUB(stash, "ASSERTION_QUERY_REQUEST_TYPE_AUTHN", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_REQUEST_TYPE_ATTRIBUTE);
    newCONSTSUB(stash, "ASSERTION_QUERY_REQUEST_TYPE_ATTRIBUTE", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_REQUEST_TYPE_AUTHZ_DECISION);
    newCONSTSUB(stash, "ASSERTION_QUERY_REQUEST_TYPE_AUTHZ_DECISION", ct);
    ct = newSViv(LASSO_ASSERTION_QUERY_REQUEST_TYPE_LAST);
    newCONSTSUB(stash, "ASSERTION_QUERY_REQUEST_TYPE_LAST", ct);
    ct = newSViv(LASSO_SAML2_ASSERTION_VALID);
    newCONSTSUB(stash, "SAML2_ASSERTION_VALID", ct);
    ct = newSViv(LASSO_SAML2_ASSERTION_INVALID);
    newCONSTSUB(stash, "SAML2_ASSERTION_INVALID", ct);
    ct = newSViv(LASSO_SAML2_ASSERTION_INDETERMINATE);
    newCONSTSUB(stash, "SAML2_ASSERTION_INDETERMINATE", ct);
    ct = newSViv(LASSO_DURATION_MINUTE);
    newCONSTSUB(stash, "DURATION_MINUTE", ct);
    ct = newSViv(LASSO_DURATION_HOUR);
    newCONSTSUB(stash, "DURATION_HOUR", ct);
    ct = newSViv(LASSO_DURATION_DAY);
    newCONSTSUB(stash, "DURATION_DAY", ct);
    ct = newSViv(LASSO_DURATION_WEEK);
    newCONSTSUB(stash, "DURATION_WEEK", ct);
    ct = newSViv(LASSO_LOGIN_PROTOCOL_PROFILE_BRWS_ART);
    newCONSTSUB(stash, "LOGIN_PROTOCOL_PROFILE_BRWS_ART", ct);
    ct = newSViv(LASSO_LOGIN_PROTOCOL_PROFILE_BRWS_POST);
    newCONSTSUB(stash, "LOGIN_PROTOCOL_PROFILE_BRWS_POST", ct);
    ct = newSViv(LASSO_LOGIN_PROTOCOL_PROFILE_BRWS_LECP);
    newCONSTSUB(stash, "LOGIN_PROTOCOL_PROFILE_BRWS_LECP", ct);
    ct = newSViv(LASSO_LOGIN_PROTOCOL_PROFILE_REDIRECT);
    newCONSTSUB(stash, "LOGIN_PROTOCOL_PROFILE_REDIRECT", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_INVALID);
    newCONSTSUB(stash, "REQUEST_TYPE_INVALID", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_LOGIN);
    newCONSTSUB(stash, "REQUEST_TYPE_LOGIN", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_LOGOUT);
    newCONSTSUB(stash, "REQUEST_TYPE_LOGOUT", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_DEFEDERATION);
    newCONSTSUB(stash, "REQUEST_TYPE_DEFEDERATION", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_NAME_REGISTRATION);
    newCONSTSUB(stash, "REQUEST_TYPE_NAME_REGISTRATION", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_NAME_IDENTIFIER_MAPPING);
    newCONSTSUB(stash, "REQUEST_TYPE_NAME_IDENTIFIER_MAPPING", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_LECP);
    newCONSTSUB(stash, "REQUEST_TYPE_LECP", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_DISCO_QUERY);
    newCONSTSUB(stash, "REQUEST_TYPE_DISCO_QUERY", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_DISCO_MODIFY);
    newCONSTSUB(stash, "REQUEST_TYPE_DISCO_MODIFY", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_DST_QUERY);
    newCONSTSUB(stash, "REQUEST_TYPE_DST_QUERY", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_DST_MODIFY);
    newCONSTSUB(stash, "REQUEST_TYPE_DST_MODIFY", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_SASL_REQUEST);
    newCONSTSUB(stash, "REQUEST_TYPE_SASL_REQUEST", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_NAME_ID_MANAGEMENT);
    newCONSTSUB(stash, "REQUEST_TYPE_NAME_ID_MANAGEMENT", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_IDWSF2_DISCO_SVCMD_REGISTER);
    newCONSTSUB(stash, "REQUEST_TYPE_IDWSF2_DISCO_SVCMD_REGISTER", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_IDWSF2_DISCO_SVCMD_ASSOCIATION_ADD);
    newCONSTSUB(stash, "REQUEST_TYPE_IDWSF2_DISCO_SVCMD_ASSOCIATION_ADD", ct);
    ct = newSViv(LASSO_REQUEST_TYPE_IDWSF2_DISCO_QUERY);
    newCONSTSUB(stash, "REQUEST_TYPE_IDWSF2_DISCO_QUERY", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_HINT_MAYBE);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_HINT_MAYBE", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_HINT_FORCE);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_HINT_FORCE", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_HINT_FORBID);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_HINT_FORBID", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_VERIFY_HINT_MAYBE);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_VERIFY_HINT_MAYBE", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_VERIFY_HINT_FORCE);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_VERIFY_HINT_FORCE", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_VERIFY_HINT_IGNORE);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_VERIFY_HINT_IGNORE", ct);
    ct = newSViv(LASSO_PROFILE_SIGNATURE_VERIFY_HINT_LAST);
    newCONSTSUB(stash, "PROFILE_SIGNATURE_VERIFY_HINT_LAST", ct);
    ct = newSViv(LASSO_HTTP_METHOD_NONE);
    newCONSTSUB(stash, "HTTP_METHOD_NONE", ct);
    ct = newSViv(LASSO_HTTP_METHOD_ANY);
    newCONSTSUB(stash, "HTTP_METHOD_ANY", ct);
    ct = newSViv(LASSO_HTTP_METHOD_IDP_INITIATED);
    newCONSTSUB(stash, "HTTP_METHOD_IDP_INITIATED", ct);
    ct = newSViv(LASSO_HTTP_METHOD_GET);
    newCONSTSUB(stash, "HTTP_METHOD_GET", ct);
    ct = newSViv(LASSO_HTTP_METHOD_POST);
    newCONSTSUB(stash, "HTTP_METHOD_POST", ct);
    ct = newSViv(LASSO_HTTP_METHOD_REDIRECT);
    newCONSTSUB(stash, "HTTP_METHOD_REDIRECT", ct);
    ct = newSViv(LASSO_HTTP_METHOD_SOAP);
    newCONSTSUB(stash, "HTTP_METHOD_SOAP", ct);
    ct = newSViv(LASSO_HTTP_METHOD_ARTIFACT_GET);
    newCONSTSUB(stash, "HTTP_METHOD_ARTIFACT_GET", ct);
    ct = newSViv(LASSO_HTTP_METHOD_ARTIFACT_POST);
    newCONSTSUB(stash, "HTTP_METHOD_ARTIFACT_POST", ct);
    ct = newSViv(LASSO_HTTP_METHOD_PAOS);
    newCONSTSUB(stash, "HTTP_METHOD_PAOS", ct);
    ct = newSViv(LASSO_HTTP_METHOD_LAST);
    newCONSTSUB(stash, "HTTP_METHOD_LAST", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_FEDERATION_TERMINATION);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_FEDERATION_TERMINATION", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_NAME_IDENTIFIER_MAPPING);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_NAME_IDENTIFIER_MAPPING", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_REGISTER_NAME_IDENTIFIER);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_REGISTER_NAME_IDENTIFIER", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_SINGLE_LOGOUT);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_SINGLE_LOGOUT", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_SINGLE_SIGN_ON);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_SINGLE_SIGN_ON", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_ARTIFACT_RESOLUTION);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_ARTIFACT_RESOLUTION", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_MANAGE_NAME_ID);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_MANAGE_NAME_ID", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_ASSERTION_ID_REQUEST);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_ASSERTION_ID_REQUEST", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_AUTHN_QUERY);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_AUTHN_QUERY", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_AUTHZ);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_AUTHZ", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_ATTRIBUTE);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_ATTRIBUTE", ct);
    ct = newSViv(LASSO_MD_PROTOCOL_TYPE_LAST);
    newCONSTSUB(stash, "MD_PROTOCOL_TYPE_LAST", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_ANY);
    newCONSTSUB(stash, "PROVIDER_ROLE_ANY", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_NONE);
    newCONSTSUB(stash, "PROVIDER_ROLE_NONE", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_SP);
    newCONSTSUB(stash, "PROVIDER_ROLE_SP", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_IDP);
    newCONSTSUB(stash, "PROVIDER_ROLE_IDP", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_BOTH);
    newCONSTSUB(stash, "PROVIDER_ROLE_BOTH", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_AUTHN_AUTHORITY);
    newCONSTSUB(stash, "PROVIDER_ROLE_AUTHN_AUTHORITY", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_AUTHZ_AUTHORITY);
    newCONSTSUB(stash, "PROVIDER_ROLE_AUTHZ_AUTHORITY", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_ATTRIBUTE_AUTHORITY);
    newCONSTSUB(stash, "PROVIDER_ROLE_ATTRIBUTE_AUTHORITY", ct);
    ct = newSViv(LASSO_PROVIDER_ROLE_LAST);
    newCONSTSUB(stash, "PROVIDER_ROLE_LAST", ct);
    ct = newSViv(LASSO_PROTOCOL_NONE);
    newCONSTSUB(stash, "PROTOCOL_NONE", ct);
    ct = newSViv(LASSO_PROTOCOL_LIBERTY_1_0);
    newCONSTSUB(stash, "PROTOCOL_LIBERTY_1_0", ct);
    ct = newSViv(LASSO_PROTOCOL_LIBERTY_1_1);
    newCONSTSUB(stash, "PROTOCOL_LIBERTY_1_1", ct);
    ct = newSViv(LASSO_PROTOCOL_LIBERTY_1_2);
    newCONSTSUB(stash, "PROTOCOL_LIBERTY_1_2", ct);
    ct = newSViv(LASSO_PROTOCOL_SAML_2_0);
    newCONSTSUB(stash, "PROTOCOL_SAML_2_0", ct);
    ct = newSViv(LASSO_ENCRYPTION_MODE_NONE);
    newCONSTSUB(stash, "ENCRYPTION_MODE_NONE", ct);
    ct = newSViv(LASSO_ENCRYPTION_MODE_NAMEID);
    newCONSTSUB(stash, "ENCRYPTION_MODE_NAMEID", ct);
    ct = newSViv(LASSO_ENCRYPTION_MODE_ASSERTION);
    newCONSTSUB(stash, "ENCRYPTION_MODE_ASSERTION", ct);
    ct = newSViv(LASSO_ENCRYPTION_SYM_KEY_TYPE_DEFAULT);
    newCONSTSUB(stash, "ENCRYPTION_SYM_KEY_TYPE_DEFAULT", ct);
    ct = newSViv(LASSO_ENCRYPTION_SYM_KEY_TYPE_AES_256);
    newCONSTSUB(stash, "ENCRYPTION_SYM_KEY_TYPE_AES_256", ct);
    ct = newSViv(LASSO_ENCRYPTION_SYM_KEY_TYPE_AES_128);
    newCONSTSUB(stash, "ENCRYPTION_SYM_KEY_TYPE_AES_128", ct);
    ct = newSViv(LASSO_ENCRYPTION_SYM_KEY_TYPE_3DES);
    newCONSTSUB(stash, "ENCRYPTION_SYM_KEY_TYPE_3DES", ct);
    ct = newSViv(LASSO_ENCRYTPION_SYM_KEY_TYPE_LAST);
    newCONSTSUB(stash, "ENCRYTPION_SYM_KEY_TYPE_LAST", ct);
    ct = newSVpv((char*)LASSO_SOAP_ENV_HREF, 0);
    newCONSTSUB(stash, "SOAP_ENV_HREF", ct);
    ct = newSVpv((char*)LASSO_SOAP_ENV_PREFIX, 0);
    newCONSTSUB(stash, "SOAP_ENV_PREFIX", ct);
    ct = newSVpv((char*)LASSO_SOAP_ENV_ACTOR, 0);
    newCONSTSUB(stash, "SOAP_ENV_ACTOR", ct);
    ct = newSVpv((char*)LASSO_SOAP_FAULT_CODE_SERVER, 0);
    newCONSTSUB(stash, "SOAP_FAULT_CODE_SERVER", ct);
    ct = newSVpv((char*)LASSO_SOAP_FAULT_CODE_CLIENT, 0);
    newCONSTSUB(stash, "SOAP_FAULT_CODE_CLIENT", ct);
    ct = newSVpv((char*)LASSO_SOAP_FAULT_CODE_MUST_UNDERSTAND, 0);
    newCONSTSUB(stash, "SOAP_FAULT_CODE_MUST_UNDERSTAND", ct);
    ct = newSVpv((char*)LASSO_SOAP_FAULT_CODE_VERSION_MISMATCH, 0);
    newCONSTSUB(stash, "SOAP_FAULT_CODE_VERSION_MISMATCH", ct);
    ct = newSVpv((char*)LASSO_PRIVATE_STATUS_CODE_FAILED_TO_RESTORE_ARTIFACT, 0);
    newCONSTSUB(stash, "PRIVATE_STATUS_CODE_FAILED_TO_RESTORE_ARTIFACT", ct);
    ct = newSVpv((char*)LASSO_WSUTIL1_HREF, 0);
    newCONSTSUB(stash, "WSUTIL1_HREF", ct);
    ct = newSVpv((char*)LASSO_WSUTIL1_PREFIX, 0);
    newCONSTSUB(stash, "WSUTIL1_PREFIX", ct);
    ct = newSVpv((char*)LASSO_LASSO_HREF, 0);
    newCONSTSUB(stash, "LASSO_HREF", ct);
    ct = newSVpv((char*)LASSO_LASSO_PREFIX, 0);
    newCONSTSUB(stash, "LASSO_PREFIX", ct);
    ct = newSVpv((char*)LASSO_PYTHON_HREF, 0);
    newCONSTSUB(stash, "PYTHON_HREF", ct);
    ct = newSVpv((char*)LASSO_SIGNATURE_TYPE_ATTRIBUTE, 0);
    newCONSTSUB(stash, "SIGNATURE_TYPE_ATTRIBUTE", ct);
    ct = newSVpv((char*)LASSO_SIGNATURE_METHOD_ATTRIBUTE, 0);
    newCONSTSUB(stash, "SIGNATURE_METHOD_ATTRIBUTE", ct);
    ct = newSVpv((char*)LASSO_PRIVATE_KEY_ATTRIBUTE, 0);
    newCONSTSUB(stash, "PRIVATE_KEY_ATTRIBUTE", ct);
    ct = newSVpv((char*)LASSO_PRIVATE_KEY_PASSWORD_ATTRIBUTE, 0);
    newCONSTSUB(stash, "PRIVATE_KEY_PASSWORD_ATTRIBUTE", ct);
    ct = newSVpv((char*)LASSO_CERTIFICATE_ATTRIBUTE, 0);
    newCONSTSUB(stash, "CERTIFICATE_ATTRIBUTE", ct);
    ct = newSVpv((char*)LASSO_LIB_HREF, 0);
    newCONSTSUB(stash, "LIB_HREF", ct);
    ct = newSVpv((char*)LASSO_LIB_PREFIX, 0);
    newCONSTSUB(stash, "LIB_PREFIX", ct);
    ct = newSViv(LASSO_LIB_MAJOR_VERSION_N);
    newCONSTSUB(stash, "LIB_MAJOR_VERSION_N", ct);
    ct = newSViv(LASSO_LIB_MINOR_VERSION_N);
    newCONSTSUB(stash, "LIB_MINOR_VERSION_N", ct);
    ct = newSVpv((char*)LASSO_LIB_NAMEID_POLICY_TYPE_NONE, 0);
    newCONSTSUB(stash, "LIB_NAMEID_POLICY_TYPE_NONE", ct);
    ct = newSVpv((char*)LASSO_LIB_NAMEID_POLICY_TYPE_ONE_TIME, 0);
    newCONSTSUB(stash, "LIB_NAMEID_POLICY_TYPE_ONE_TIME", ct);
    ct = newSVpv((char*)LASSO_LIB_NAMEID_POLICY_TYPE_FEDERATED, 0);
    newCONSTSUB(stash, "LIB_NAMEID_POLICY_TYPE_FEDERATED", ct);
    ct = newSVpv((char*)LASSO_LIB_NAMEID_POLICY_TYPE_ANY, 0);
    newCONSTSUB(stash, "LIB_NAMEID_POLICY_TYPE_ANY", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_INTERNET_PROTOCOL, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_INTERNET_PROTOCOL", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_INTERNET_PROTOCOL_PASSWORD, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_INTERNET_PROTOCOL_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_ONE_FACTOR_UNREGISTERED, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_ONE_FACTOR_UNREGISTERED", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_TWO_FACTOR_UNREGISTERED, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_TWO_FACTOR_UNREGISTERED", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_ONE_FACTOR_CONTRACT, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_ONE_FACTOR_CONTRACT", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_TWO_FACTOR_CONTRACT, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_MOBILE_TWO_FACTOR_CONTRACT", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_PASSWORD, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_PASSWORD_PROTECTED_TRANSPORT, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_PASSWORD_PROTECTED_TRANSPORT", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_PREVIOUS_SESSION, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_PREVIOUS_SESSION", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_SMARTCARD, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_SMARTCARD", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_SMARTCARD_PKI, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_SMARTCARD_PKI", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_SOFTWARE_PKI, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_SOFTWARE_PKI", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_CLASS_REF_TIME_SYNC_TOKEN, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_CLASS_REF_TIME_SYNC_TOKEN", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_COMPARISON_EXACT, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_COMPARISON_EXACT", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_COMPARISON_MINIMUM, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_COMPARISON_MINIMUM", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_COMPARISON_MAXIMUM, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_COMPARISON_MAXIMUM", ct);
    ct = newSVpv((char*)LASSO_LIB_AUTHN_CONTEXT_COMPARISON_BETTER, 0);
    newCONSTSUB(stash, "LIB_AUTHN_CONTEXT_COMPARISON_BETTER", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_FEDERATION_DOES_NOT_EXIST, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_FEDERATION_DOES_NOT_EXIST", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_INVALID_ASSERTION_CONSUMER_SERVICE_INDEX, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_INVALID_ASSERTION_CONSUMER_SERVICE_INDEX", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_INVALID_SIGNATURE, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_INVALID_SIGNATURE", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_NO_AUTHN_CONTEXT, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_NO_AUTHN_CONTEXT", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_NO_AVAILABLEIDP, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_NO_AVAILABLEIDP", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_NO_PASSIVE, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_NO_PASSIVE", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_NO_SUPPORTEDIDP, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_NO_SUPPORTEDIDP", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_PROXY_COUNT_EXCEEDED, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_PROXY_COUNT_EXCEEDED", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_UNKNOWN_PRINCIPAL, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_UNKNOWN_PRINCIPAL", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_UNSIGNED_AUTHN_REQUEST, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_UNSIGNED_AUTHN_REQUEST", ct);
    ct = newSVpv((char*)LASSO_LIB_STATUS_CODE_UNSUPPORTED_PROFILE, 0);
    newCONSTSUB(stash, "LIB_STATUS_CODE_UNSUPPORTED_PROFILE", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_BRWS_ART, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_BRWS_ART", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_BRWS_POST, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_BRWS_POST", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_BRWS_LECP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_BRWS_LECP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_FED_TERM_IDP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_FED_TERM_IDP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_FED_TERM_IDP_SOAP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_FED_TERM_IDP_SOAP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_FED_TERM_SP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_FED_TERM_SP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_FED_TERM_SP_SOAP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_FED_TERM_SP_SOAP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_NIM_SP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_NIM_SP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_RNI_IDP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_RNI_IDP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_RNI_IDP_SOAP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_RNI_IDP_SOAP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_RNI_SP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_RNI_SP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_RNI_SP_SOAP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_RNI_SP_SOAP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_SLO_SP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_SLO_SP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_SLO_SP_SOAP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_SLO_SP_SOAP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_SLO_IDP_HTTP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_SLO_IDP_HTTP", ct);
    ct = newSVpv((char*)LASSO_LIB_PROTOCOL_PROFILE_SLO_IDP_SOAP, 0);
    newCONSTSUB(stash, "LIB_PROTOCOL_PROFILE_SLO_IDP_SOAP", ct);
    ct = newSVpv((char*)LASSO_LIB_NAME_IDENTIFIER_FORMAT_FEDERATED, 0);
    newCONSTSUB(stash, "LIB_NAME_IDENTIFIER_FORMAT_FEDERATED", ct);
    ct = newSVpv((char*)LASSO_LIB_NAME_IDENTIFIER_FORMAT_ONE_TIME, 0);
    newCONSTSUB(stash, "LIB_NAME_IDENTIFIER_FORMAT_ONE_TIME", ct);
    ct = newSVpv((char*)LASSO_LIB_NAME_IDENTIFIER_FORMAT_ENCRYPTED, 0);
    newCONSTSUB(stash, "LIB_NAME_IDENTIFIER_FORMAT_ENCRYPTED", ct);
    ct = newSVpv((char*)LASSO_LIB_NAME_IDENTIFIER_FORMAT_ENTITYID, 0);
    newCONSTSUB(stash, "LIB_NAME_IDENTIFIER_FORMAT_ENTITYID", ct);
    ct = newSVpv((char*)LASSO_LIB_CONSENT_OBTAINED, 0);
    newCONSTSUB(stash, "LIB_CONSENT_OBTAINED", ct);
    ct = newSVpv((char*)LASSO_LIB_CONSENT_OBTAINED_PRIOR, 0);
    newCONSTSUB(stash, "LIB_CONSENT_OBTAINED_PRIOR", ct);
    ct = newSVpv((char*)LASSO_LIB_CONSENT_OBTAINED_CURRENT_IMPLICIT, 0);
    newCONSTSUB(stash, "LIB_CONSENT_OBTAINED_CURRENT_IMPLICIT", ct);
    ct = newSVpv((char*)LASSO_LIB_CONSENT_OBTAINED_CURRENT_EXPLICIT, 0);
    newCONSTSUB(stash, "LIB_CONSENT_OBTAINED_CURRENT_EXPLICIT", ct);
    ct = newSVpv((char*)LASSO_LIB_CONSENT_UNAVAILABLE, 0);
    newCONSTSUB(stash, "LIB_CONSENT_UNAVAILABLE", ct);
    ct = newSVpv((char*)LASSO_LIB_CONSENT_INAPPLICABLE, 0);
    newCONSTSUB(stash, "LIB_CONSENT_INAPPLICABLE", ct);
    ct = newSVpv((char*)LASSO_METADATA_HREF, 0);
    newCONSTSUB(stash, "METADATA_HREF", ct);
    ct = newSVpv((char*)LASSO_METADATA_PREFIX, 0);
    newCONSTSUB(stash, "METADATA_PREFIX", ct);
    ct = newSVpv((char*)LASSO_SAML_ASSERTION_HREF, 0);
    newCONSTSUB(stash, "SAML_ASSERTION_HREF", ct);
    ct = newSVpv((char*)LASSO_SAML_ASSERTION_PREFIX, 0);
    newCONSTSUB(stash, "SAML_ASSERTION_PREFIX", ct);
    ct = newSVpv((char*)LASSO_SAML_PROTOCOL_HREF, 0);
    newCONSTSUB(stash, "SAML_PROTOCOL_HREF", ct);
    ct = newSVpv((char*)LASSO_SAML_PROTOCOL_PREFIX, 0);
    newCONSTSUB(stash, "SAML_PROTOCOL_PREFIX", ct);
    ct = newSViv(LASSO_SAML_MAJOR_VERSION_N);
    newCONSTSUB(stash, "SAML_MAJOR_VERSION_N", ct);
    ct = newSViv(LASSO_SAML_MINOR_VERSION_N);
    newCONSTSUB(stash, "SAML_MINOR_VERSION_N", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_SUCCESS, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_SUCCESS", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_VERSION_MISMATCH, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_VERSION_MISMATCH", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_REQUESTER, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_REQUESTER", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_RESPONDER, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_RESPONDER", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_REQUEST_VERSION_TOO_HIGH, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_REQUEST_VERSION_TOO_HIGH", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_REQUEST_VERSION_TOO_LOW, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_REQUEST_VERSION_TOO_LOW", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_REQUEST_VERSION_DEPRECATED, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_REQUEST_VERSION_DEPRECATED", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_TOO_MANY_RESPONSES, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_TOO_MANY_RESPONSES", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_RESOURCE_NOT_RECOGNIZED, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_RESOURCE_NOT_RECOGNIZED", ct);
    ct = newSVpv((char*)LASSO_SAML_STATUS_CODE_REQUEST_DENIED, 0);
    newCONSTSUB(stash, "SAML_STATUS_CODE_REQUEST_DENIED", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_PASSWORD, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_KERBEROS, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_KERBEROS", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_SECURE_REMOTE_PASSWORD, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_SECURE_REMOTE_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_HARDWARE_TOKEN, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_HARDWARE_TOKEN", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_SMARTCARD_PKI, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_SMARTCARD_PKI", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_SOFTWARE_PKI, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_SOFTWARE_PKI", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_PGP, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_PGP", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHODS_PKI, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHODS_PKI", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_XKMS, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_XKMS", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_XMLD_SIG, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_XMLD_SIG", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_UNSPECIFIED, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_UNSPECIFIED", ct);
    ct = newSVpv((char*)LASSO_SAML_AUTHENTICATION_METHOD_LIBERTY, 0);
    newCONSTSUB(stash, "SAML_AUTHENTICATION_METHOD_LIBERTY", ct);
    ct = newSVpv((char*)LASSO_SAML_CONFIRMATION_METHOD_ARTIFACT, 0);
    newCONSTSUB(stash, "SAML_CONFIRMATION_METHOD_ARTIFACT", ct);
    ct = newSVpv((char*)LASSO_SAML_CONFIRMATION_METHOD_ARTIFACT01, 0);
    newCONSTSUB(stash, "SAML_CONFIRMATION_METHOD_ARTIFACT01", ct);
    ct = newSVpv((char*)LASSO_SAML_CONFIRMATION_METHOD_BEARER, 0);
    newCONSTSUB(stash, "SAML_CONFIRMATION_METHOD_BEARER", ct);
    ct = newSVpv((char*)LASSO_SAML_CONFIRMATION_METHOD_HOLDER_OF_KEY, 0);
    newCONSTSUB(stash, "SAML_CONFIRMATION_METHOD_HOLDER_OF_KEY", ct);
    ct = newSVpv((char*)LASSO_SAML_CONFIRMATION_METHOD_SENDER_VOUCHES, 0);
    newCONSTSUB(stash, "SAML_CONFIRMATION_METHOD_SENDER_VOUCHES", ct);
    ct = newSVpv((char*)LASSO_PAOS_HREF, 0);
    newCONSTSUB(stash, "PAOS_HREF", ct);
    ct = newSVpv((char*)LASSO_PAOS_PREFIX, 0);
    newCONSTSUB(stash, "PAOS_PREFIX", ct);
    ct = newSVpv((char*)LASSO_ECP_HREF, 0);
    newCONSTSUB(stash, "ECP_HREF", ct);
    ct = newSVpv((char*)LASSO_ECP_PREFIX, 0);
    newCONSTSUB(stash, "ECP_PREFIX", ct);
    ct = newSVpv((char*)LASSO_DS_HREF, 0);
    newCONSTSUB(stash, "DS_HREF", ct);
    ct = newSVpv((char*)LASSO_DS_PREFIX, 0);
    newCONSTSUB(stash, "DS_PREFIX", ct);
    ct = newSVpv((char*)LASSO_XSI_HREF, 0);
    newCONSTSUB(stash, "XSI_HREF", ct);
    ct = newSVpv((char*)LASSO_XSI_PREFIX, 0);
    newCONSTSUB(stash, "XSI_PREFIX", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_XSCHEMA_ERROR);
    newCONSTSUB(stash, "MESSAGE_FORMAT_XSCHEMA_ERROR", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_ERROR);
    newCONSTSUB(stash, "MESSAGE_FORMAT_ERROR", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_UNKNOWN);
    newCONSTSUB(stash, "MESSAGE_FORMAT_UNKNOWN", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_XML);
    newCONSTSUB(stash, "MESSAGE_FORMAT_XML", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_BASE64);
    newCONSTSUB(stash, "MESSAGE_FORMAT_BASE64", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_QUERY);
    newCONSTSUB(stash, "MESSAGE_FORMAT_QUERY", ct);
    ct = newSViv(LASSO_MESSAGE_FORMAT_SOAP);
    newCONSTSUB(stash, "MESSAGE_FORMAT_SOAP", ct);
    ct = newSViv(LASSO_SIGNATURE_TYPE_NONE);
    newCONSTSUB(stash, "SIGNATURE_TYPE_NONE", ct);
    ct = newSViv(LASSO_SIGNATURE_TYPE_SIMPLE);
    newCONSTSUB(stash, "SIGNATURE_TYPE_SIMPLE", ct);
    ct = newSViv(LASSO_SIGNATURE_TYPE_WITHX509);
    newCONSTSUB(stash, "SIGNATURE_TYPE_WITHX509", ct);
    ct = newSViv(LASSO_SIGNATURE_TYPE_LAST);
    newCONSTSUB(stash, "SIGNATURE_TYPE_LAST", ct);
    ct = newSViv(LASSO_SIGNATURE_METHOD_RSA_SHA1);
    newCONSTSUB(stash, "SIGNATURE_METHOD_RSA_SHA1", ct);
    ct = newSViv(LASSO_SIGNATURE_METHOD_DSA_SHA1);
    newCONSTSUB(stash, "SIGNATURE_METHOD_DSA_SHA1", ct);
    ct = newSViv(LASSO_SIGNATURE_METHOD_LAST);
    newCONSTSUB(stash, "SIGNATURE_METHOD_LAST", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_HREF, 0);
    newCONSTSUB(stash, "SAML2_METADATA_HREF", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_PREFIX, 0);
    newCONSTSUB(stash, "SAML2_METADATA_PREFIX", ct);
    ct = newSVpv((char*)LASSO_SAML2_PROTOCOL_HREF, 0);
    newCONSTSUB(stash, "SAML2_PROTOCOL_HREF", ct);
    ct = newSVpv((char*)LASSO_SAML2_PROTOCOL_PREFIX, 0);
    newCONSTSUB(stash, "SAML2_PROTOCOL_PREFIX", ct);
    ct = newSVpv((char*)LASSO_SAML2_ASSERTION_HREF, 0);
    newCONSTSUB(stash, "SAML2_ASSERTION_HREF", ct);
    ct = newSVpv((char*)LASSO_SAML2_ASSERTION_PREFIX, 0);
    newCONSTSUB(stash, "SAML2_ASSERTION_PREFIX", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_BINDING_SOAP, 0);
    newCONSTSUB(stash, "SAML2_METADATA_BINDING_SOAP", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_BINDING_REDIRECT, 0);
    newCONSTSUB(stash, "SAML2_METADATA_BINDING_REDIRECT", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_BINDING_POST, 0);
    newCONSTSUB(stash, "SAML2_METADATA_BINDING_POST", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_BINDING_ARTIFACT, 0);
    newCONSTSUB(stash, "SAML2_METADATA_BINDING_ARTIFACT", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_BINDING_PAOS, 0);
    newCONSTSUB(stash, "SAML2_METADATA_BINDING_PAOS", ct);
    ct = newSVpv((char*)LASSO_SAML2_METADATA_BINDING_URI, 0);
    newCONSTSUB(stash, "SAML2_METADATA_BINDING_URI", ct);
    ct = newSVpv((char*)LASSO_SAML2_DEFLATE_ENCODING, 0);
    newCONSTSUB(stash, "SAML2_DEFLATE_ENCODING", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_UNSPECIFIED, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_UNSPECIFIED", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_EMAIL, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_EMAIL", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_X509, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_X509", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_WINDOWS, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_WINDOWS", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_KERBEROS, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_KERBEROS", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_ENTITY, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_ENTITY", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_PERSISTENT, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_PERSISTENT", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_TRANSIENT, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_TRANSIENT", ct);
    ct = newSVpv((char*)LASSO_SAML2_NAME_IDENTIFIER_FORMAT_ENCRYPTED, 0);
    newCONSTSUB(stash, "SAML2_NAME_IDENTIFIER_FORMAT_ENCRYPTED", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_NAME_EPR, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_NAME_EPR", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_NAME_FORMAT_UNSPECIFIED, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_NAME_FORMAT_UNSPECIFIED", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_NAME_FORMAT_URI, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_NAME_FORMAT_URI", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_NAME_FORMAT_BASIC, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_NAME_FORMAT_BASIC", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_NAMESPACE_RWEDC, 0);
    newCONSTSUB(stash, "SAML2_ACTION_NAMESPACE_RWEDC", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_NAMESPACE_RWEDC_NEGATION, 0);
    newCONSTSUB(stash, "SAML2_ACTION_NAMESPACE_RWEDC_NEGATION", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_NAMESPACE_GHPP, 0);
    newCONSTSUB(stash, "SAML2_ACTION_NAMESPACE_GHPP", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_NAMESPACE_UNIX, 0);
    newCONSTSUB(stash, "SAML2_ACTION_NAMESPACE_UNIX", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_RWEDC_READ, 0);
    newCONSTSUB(stash, "SAML2_ACTION_RWEDC_READ", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_RWEDC_WRITE, 0);
    newCONSTSUB(stash, "SAML2_ACTION_RWEDC_WRITE", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_RWEDC_EXECUTE, 0);
    newCONSTSUB(stash, "SAML2_ACTION_RWEDC_EXECUTE", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_RWEDC_DELETE, 0);
    newCONSTSUB(stash, "SAML2_ACTION_RWEDC_DELETE", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_RWEDC_CONTROL, 0);
    newCONSTSUB(stash, "SAML2_ACTION_RWEDC_CONTROL", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_RWEDC_NEGATION, 0);
    newCONSTSUB(stash, "SAML2_ACTION_RWEDC_NEGATION", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_GHPP_GET, 0);
    newCONSTSUB(stash, "SAML2_ACTION_GHPP_GET", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_GHPP_HEAD, 0);
    newCONSTSUB(stash, "SAML2_ACTION_GHPP_HEAD", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_GHPP_PUT, 0);
    newCONSTSUB(stash, "SAML2_ACTION_GHPP_PUT", ct);
    ct = newSVpv((char*)LASSO_SAML2_ACTION_GHPP_POST, 0);
    newCONSTSUB(stash, "SAML2_ACTION_GHPP_POST", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONSENT_OBTAINED, 0);
    newCONSTSUB(stash, "SAML2_CONSENT_OBTAINED", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONSENT_PRIOR, 0);
    newCONSTSUB(stash, "SAML2_CONSENT_PRIOR", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONSENT_IMPLICIT, 0);
    newCONSTSUB(stash, "SAML2_CONSENT_IMPLICIT", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONSENT_EXPLICIT, 0);
    newCONSTSUB(stash, "SAML2_CONSENT_EXPLICIT", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONSENT_UNAVAILABLE, 0);
    newCONSTSUB(stash, "SAML2_CONSENT_UNAVAILABLE", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONSENT_INAPPLICABLE, 0);
    newCONSTSUB(stash, "SAML2_CONSENT_INAPPLICABLE", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_SUCCESS, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_SUCCESS", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_REQUESTER, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_REQUESTER", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_RESPONDER, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_RESPONDER", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_VERSION_MISMATCH, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_VERSION_MISMATCH", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_AUTHN_FAILED, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_AUTHN_FAILED", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_INVALID_ATTR_NAME, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_INVALID_ATTR_NAME", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_INVALID_NAME_ID_POLICY, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_INVALID_NAME_ID_POLICY", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_NO_AUTHN_CONTEXT, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_NO_AUTHN_CONTEXT", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_NO_AVAILABLE_IDP, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_NO_AVAILABLE_IDP", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_NO_PASSIVE, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_NO_PASSIVE", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_NO_SUPPORTED_IDP, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_NO_SUPPORTED_IDP", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_PARTIAL_LOGOUT, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_PARTIAL_LOGOUT", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_PROXY_COUNT_EXCEEDED, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_PROXY_COUNT_EXCEEDED", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_REQUEST_DENIED, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_REQUEST_DENIED", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_REQUEST_UNSUPPORTED, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_REQUEST_UNSUPPORTED", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_REQUEST_VERSION_DEPRECATED, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_REQUEST_VERSION_DEPRECATED", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_REQUEST_VERSION_TOO_HIGH, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_REQUEST_VERSION_TOO_HIGH", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_REQUEST_VERSION_TOO_LOW, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_REQUEST_VERSION_TOO_LOW", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_RESOURCE_NOT_RECOGNIZED, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_RESOURCE_NOT_RECOGNIZED", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_TOO_MANY_RESPONSES, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_TOO_MANY_RESPONSES", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_UNKNOWN_ATTR_PROFILE, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_UNKNOWN_ATTR_PROFILE", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_UNKNOWN_PRINCIPAL, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_UNKNOWN_PRINCIPAL", ct);
    ct = newSVpv((char*)LASSO_SAML2_STATUS_CODE_UNSUPPORTED_BINDING, 0);
    newCONSTSUB(stash, "SAML2_STATUS_CODE_UNSUPPORTED_BINDING", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_AUTHENTICATED_TELEPHONY, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_AUTHENTICATED_TELEPHONY", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_INTERNET_PROTOCOL, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_INTERNET_PROTOCOL", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_INTERNET_PROTOCOL_PASSWORD, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_INTERNET_PROTOCOL_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_KERBEROS, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_KERBEROS", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_MOBILE_ONE_FACTOR_CONTRACT, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_MOBILE_ONE_FACTOR_CONTRACT", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_MOBILE_ONE_FACTOR_UNREGISTERED, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_MOBILE_ONE_FACTOR_UNREGISTERED", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_MOBILE_TWO_FACTOR_CONTRACT, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_MOBILE_TWO_FACTOR_CONTRACT", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_MOBILE_TWO_FACTOR_UNREGISTERED, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_MOBILE_TWO_FACTOR_UNREGISTERED", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_NOMAD_TELEPHONY, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_NOMAD_TELEPHONY", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_PERSONALIZED_TELEPHONY, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_PERSONALIZED_TELEPHONY", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_PGP, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_PGP", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_PASSWORD_PROTECTED_TRANSPORT, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_PASSWORD_PROTECTED_TRANSPORT", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_PASSWORD, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_PREVIOUS_SESSION, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_PREVIOUS_SESSION", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_SMARTCARD, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_SMARTCARD", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_SMARTCARD_PKI, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_SMARTCARD_PKI", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_SOFTWARE_PKI, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_SOFTWARE_PKI", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_SPKI, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_SPKI", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_SECURE_REMOTE_PASSWORD, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_SECURE_REMOTE_PASSWORD", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_TLS_CLIENT, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_TLS_CLIENT", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_X509, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_X509", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_TELEPHONY, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_TELEPHONY", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_TIME_SYNC_TOKEN, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_TIME_SYNC_TOKEN", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_XMLDSIG, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_XMLDSIG", ct);
    ct = newSVpv((char*)LASSO_SAML2_AUTHN_CONTEXT_UNSPECIFIED, 0);
    newCONSTSUB(stash, "SAML2_AUTHN_CONTEXT_UNSPECIFIED", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONFIRMATION_METHOD_BEARER, 0);
    newCONSTSUB(stash, "SAML2_CONFIRMATION_METHOD_BEARER", ct);
    ct = newSVpv((char*)LASSO_SAML2_CONFIRMATION_METHOD_HOLDER_OF_KEY, 0);
    newCONSTSUB(stash, "SAML2_CONFIRMATION_METHOD_HOLDER_OF_KEY", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_ENCODING, 0);
    newCONSTSUB(stash, "SAML2_FIELD_ENCODING", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_RESPONSE, 0);
    newCONSTSUB(stash, "SAML2_FIELD_RESPONSE", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_REQUEST, 0);
    newCONSTSUB(stash, "SAML2_FIELD_REQUEST", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_ARTIFACT, 0);
    newCONSTSUB(stash, "SAML2_FIELD_ARTIFACT", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_RELAYSTATE, 0);
    newCONSTSUB(stash, "SAML2_FIELD_RELAYSTATE", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_SIGNATURE, 0);
    newCONSTSUB(stash, "SAML2_FIELD_SIGNATURE", ct);
    ct = newSVpv((char*)LASSO_SAML2_FIELD_SIGALG, 0);
    newCONSTSUB(stash, "SAML2_FIELD_SIGALG", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_PROFILE_BASIC, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_PROFILE_BASIC", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_PROFILE_X500, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_PROFILE_X500", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_PROFILE_UUID, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_PROFILE_UUID", ct);
    ct = newSVpv((char*)LASSO_SAML2_ATTRIBUTE_PROFILE_DCE, 0);
    newCONSTSUB(stash, "SAML2_ATTRIBUTE_PROFILE_DCE", ct);
#ifdef LASSO_WSF_ENABLED
        ct = newSViv(1);
#else
        ct = newSViv(0);
#endif
    newCONSTSUB(stash, "WSF_ENABLED", ct);
}

lasso_error_t
lasso_init(  )
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_shutdown(  )
  CLEANUP:
    gperl_lasso_error(RETVAL);

int
lasso_check_version( major,minor,subminor,mode = LASSO_CHECK_VERSION_NUMERIC )
  int major
  int minor
  int subminor
  LassoCheckVersionMode mode

void
lasso_set_flag( flag )
  string_non_null flag

const char*
lasso_strerror( error_code )
  int error_code

gboolean
lasso_profile_is_saml_query( query )
  string_non_null query

LassoSaml2NameID*
lasso_saml2_name_id_build_persistent( id,idpID,providerID )
  string_non_null id
  string_non_null idpID
  string_non_null providerID
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2EncryptedElement*
lasso_saml2_encrypted_element_build_encrypted_persistent_name_id( id,idpID,provider )
  string_non_null id
  string_non_null idpID
  LassoProvider* provider
  CLEANUP:
    lasso_unref(RETVAL);

LassoRequestType
lasso_profile_get_request_type_from_soap_msg( soap )
  string_non_null soap

gboolean
lasso_profile_is_liberty_query( query )
  string_non_null query

void
lasso_register_dst_service( prefix,href )
  string_non_null prefix
  string_non_null href

char*
lasso_get_prefix_for_dst_service_href( href )
  string_non_null href

void
lasso_register_idwsf2_dst_service( prefix,href )
  string_non_null prefix
  string_non_null href

gchar*
lasso_get_prefix_for_idwsf2_dst_service_href( href )
  string_non_null href

char*
lasso_build_unique_id( size )
  unsigned int size

MODULE = Lasso	PACKAGE = Lasso::Node	PREFIX = lasso_node_


LassoNode*
lasso_node_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_node_new_from_dump( dump )
  string_non_null dump
   CODE:
       RETVAL = (LassoNode*)lasso_node_new_from_dump(dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_node_new_from_soap( soap )
  string_non_null soap
   CODE:
       RETVAL = (LassoNode*)lasso_node_new_from_soap(soap);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_node_new_from_xmlNode( node )
  xmlNode* node
   CODE:
       RETVAL = (LassoNode*)lasso_node_new_from_xmlNode(node);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_release_xml_node(node)
    lasso_unref(RETVAL);

void
lasso_node_cleanup_original_xmlnodes( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_dump( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_export_to_base64( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_export_to_query( node,sign_method = 1,private_key_file = NULL )
  LassoNode* node
  LassoSignatureMethod sign_method
  string_or_null private_key_file
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_export_to_query_with_password( node,sign_method = 1,private_key_file = NULL,private_key_file_password = NULL )
  LassoNode* node
  LassoSignatureMethod sign_method
  string_or_null private_key_file
  string_or_null private_key_file_password
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_export_to_soap( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

gchar*
lasso_node_export_to_xml( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_export_to_paos_request( node,issuer,responseConsumerURL,relay_state )
  LassoNode* node
  string_non_null issuer
  string_non_null responseConsumerURL
  string_non_null relay_state
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

char*
lasso_node_export_to_ecp_soap_response( node,assertionConsumerURL )
  LassoNode* node
  string_non_null assertionConsumerURL
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

xmlNode*
lasso_node_get_xmlNode( node,lasso_dump )
  LassoNode* node
  gboolean lasso_dump
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

xmlNode*
lasso_node_get_original_xmlnode( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

void
lasso_node_set_original_xmlnode( node,xmlnode )
  LassoNode* node
  xmlNode* xmlnode
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());
  CLEANUP:
    lasso_release_xml_node(xmlnode)

void
lasso_node_set_custom_namespace( node,prefix,href )
  LassoNode* node
  string_non_null prefix
  string_non_null href
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

void
lasso_node_set_custom_nodename( node,nodename )
  LassoNode* node
  string_non_null nodename
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

const char*
lasso_node_get_name( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

const char*
lasso_node_get_namespace( node )
  LassoNode* node
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

LassoMessageFormat
lasso_node_init_from_message( node,message )
  LassoNode* node
  string_non_null message
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

gboolean
lasso_node_init_from_query( node,query )
  LassoNode* node
  string_non_null query
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

lasso_error_t
lasso_node_init_from_xml( node,xmlnode )
  LassoNode* node
  xmlNode* xmlnode
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());
  CLEANUP:
    lasso_release_xml_node(xmlnode)
    gperl_lasso_error(RETVAL);

char*
lasso_node_debug( node,level = 10 )
  LassoNode* node
  int level
  INIT:
    check_gobject((GObject*)node, lasso_node_get_type());

MODULE = Lasso	PACKAGE = Lasso::Identity	PREFIX = lasso_identity_


LassoIdentity*
lasso_identity_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoIdentity*
lasso_identity_new_from_dump( dump )
  string_non_null dump
   CODE:
       RETVAL = (LassoIdentity*)lasso_identity_new_from_dump(dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoFederation*
lasso_identity_get_federation( identity,providerID )
  LassoIdentity* identity
  string_non_null providerID
  INIT:
    check_gobject((GObject*)identity, lasso_identity_get_type());

gchar*
lasso_identity_dump( identity )
  LassoIdentity* identity
  INIT:
    check_gobject((GObject*)identity, lasso_identity_get_type());

HV*
federations(LassoIdentity* obj, ...)
    PROTOTYPE:
        $;\%
    CODE:
        if (items > 1) { /* setter */
            if (SvTYPE(ST(1)) != SVt_RV || ! SvTYPE(SvRV(ST(1))) != SVt_PVHV) {
                sv_dump(ST(1));
                croak("Lasso::Identity::federations takes a reference to a hash as argument");
            }
            set_hash_of_objects(&obj->federations, (HV*)SvRV(ST(1)));
        }
        RETVAL = get_hash_of_objects(obj->federations);
        sv_2mortal((SV*)RETVAL);
    OUTPUT:
        RETVAL


gboolean
is_dirty(LassoIdentity* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->is_dirty, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->is_dirty;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Session	PREFIX = lasso_session_


LassoSession*
lasso_session_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSession*
lasso_session_new_from_dump( dump )
  string_non_null dump
   CODE:
       RETVAL = (LassoSession*)lasso_session_new_from_dump(dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

gchar*
lasso_session_dump( session )
  LassoSession* session
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());

GList_gobject
lasso_session_get_assertions( session,provider_id = NULL )
  LassoSession* session
  string_or_null provider_id
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());

gchar*
lasso_session_get_provider_index( session,index )
  LassoSession* session
  gint index
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());

gboolean
lasso_session_is_empty( session )
  LassoSession* session
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());

lasso_error_t
lasso_session_remove_assertion( session,providerID )
  LassoSession* session
  string_non_null providerID
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoNode*
lasso_session_get_assertion( session,providerID )
  LassoSession* session
  string_non_null providerID
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_session_add_assertion( session,providerID,assertion )
  LassoSession* session
  string_non_null providerID
  LassoNode* assertion
  INIT:
    check_gobject((GObject*)session, lasso_session_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

HV*
assertions(LassoSession* obj, ...)
    PROTOTYPE:
        $;\%
    CODE:
        if (items > 1) { /* setter */
            if (SvTYPE(ST(1)) != SVt_RV || ! SvTYPE(SvRV(ST(1))) != SVt_PVHV) {
                sv_dump(ST(1));
                croak("Lasso::Session::assertions takes a reference to a hash as argument");
            }
            set_hash_of_objects(&obj->assertions, (HV*)SvRV(ST(1)));
        }
        RETVAL = get_hash_of_objects(obj->assertions);
        sv_2mortal((SV*)RETVAL);
    OUTPUT:
        RETVAL


gboolean
is_dirty(LassoSession* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->is_dirty, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->is_dirty;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Federation	PREFIX = lasso_federation_


LassoFederation*
lasso_federation_new( cls,remote_providerID )
  char *cls
  string_non_null remote_providerID
  INIT:
    cls = NULL;
  C_ARGS:
    remote_providerID
  CLEANUP:
    lasso_unref(RETVAL);

void
lasso_federation_build_local_name_identifier( federation,nameQualifier,format,content )
  LassoFederation* federation
  string_non_null nameQualifier
  string_non_null format
  string_non_null content
  INIT:
    check_gobject((GObject*)federation, lasso_federation_get_type());

gboolean
lasso_federation_verify_name_identifier( federation,name_identifier )
  LassoFederation* federation
  LassoNode* name_identifier
  INIT:
    check_gobject((GObject*)federation, lasso_federation_get_type());

gchar*
remote_providerID(LassoFederation* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->remote_providerID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->remote_providerID;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
local_nameIdentifier(LassoFederation* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->local_nameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->local_nameIdentifier;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
remote_nameIdentifier(LassoFederation* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->remote_nameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->remote_nameIdentifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Profile	PREFIX = lasso_profile_


LassoIdentity*
lasso_profile_get_identity( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

LassoSession*
lasso_profile_get_session( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

gboolean
lasso_profile_is_identity_dirty( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

gboolean
lasso_profile_is_session_dirty( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

lasso_error_t
lasso_profile_set_identity_from_dump( profile,dump )
  LassoProfile* profile
  string_non_null dump
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_profile_set_session_from_dump( profile,dump )
  LassoProfile* profile
  string_non_null dump
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoNode*
lasso_profile_get_nameIdentifier( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

char*
lasso_profile_get_artifact( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

char*
lasso_profile_get_artifact_message( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

void
lasso_profile_set_artifact_message( profile,message )
  LassoProfile* profile
  string_non_null message
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

void
lasso_profile_set_signature_hint( profile,signature_hint )
  LassoProfile* profile
  LassoProfileSignatureHint signature_hint
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

LassoProfileSignatureHint
lasso_profile_get_signature_hint( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

lasso_error_t
lasso_profile_set_soap_fault_response( profile,faultcode,faultstring = NULL,details = NULL )
  LassoProfile* profile
  string_non_null faultcode
  string_or_null faultstring
  GList_gobject details
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());
PROTOTYPE:  $$;$\@
  CLEANUP:
    lasso_release_list_of_gobjects(details);
    gperl_lasso_error(RETVAL);

void
lasso_profile_set_signature_verify_hint( profile,signature_verify_hint )
  LassoProfile* profile
  LassoProfileSignatureVerifyHint signature_verify_hint
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

LassoProfileSignatureVerifyHint
lasso_profile_get_signature_verify_hint( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

LassoProviderRole
lasso_profile_sso_role_with( profile,remote_provider_id )
  LassoProfile* profile
  string_non_null remote_provider_id
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());

lasso_error_t
lasso_profile_get_signature_status( profile )
  LassoProfile* profile
  INIT:
    check_gobject((GObject*)profile, lasso_profile_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoServer*
server(LassoProfile* obj, LassoServer* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->server, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->server;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
request(LassoProfile* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->request, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->request;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
response(LassoProfile* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->response, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->response;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
nameIdentifier(LassoProfile* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->nameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->nameIdentifier;
        }
    OUTPUT:
        RETVAL

            

gchar*
remote_providerID(LassoProfile* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->remote_providerID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->remote_providerID;
        }
    OUTPUT:
        RETVAL

            

gchar*
msg_url(LassoProfile* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->msg_url, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->msg_url;
        }
    OUTPUT:
        RETVAL

            

gchar*
msg_body(LassoProfile* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->msg_body, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->msg_body;
        }
    OUTPUT:
        RETVAL

            

gchar*
msg_relayState(LassoProfile* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->msg_relayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->msg_relayState;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Ecp	PREFIX = lasso_ecp_


LassoEcp*
lasso_ecp_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_ecp_process_authn_request_msg( ecp,authn_request_msg )
  LassoEcp* ecp
  string_non_null authn_request_msg
  INIT:
    check_gobject((GObject*)ecp, lasso_ecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_ecp_process_response_msg( ecp,response_msg )
  LassoEcp* ecp
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)ecp, lasso_ecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gchar*
assertionConsumerURL(LassoEcp* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->assertionConsumerURL, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->assertionConsumerURL;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::AssertionQuery	PREFIX = lasso_assertion_query_


LassoAssertionQuery*
lasso_assertion_query_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_assertion_query_init_request( assertion_query,remote_provider_id = NULL,http_method,query_request_type )
  LassoAssertionQuery* assertion_query
  string_or_null remote_provider_id
  LassoHttpMethod http_method
  LassoAssertionQueryRequestType query_request_type
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_assertion_query_validate_request( assertion_query )
  LassoAssertionQuery* assertion_query
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_assertion_query_build_request_msg( assertion_query )
  LassoAssertionQuery* assertion_query
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_assertion_query_process_request_msg( assertion_query,request_msg )
  LassoAssertionQuery* assertion_query
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_assertion_query_build_response_msg( assertion_query )
  LassoAssertionQuery* assertion_query
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_assertion_query_process_response_msg( assertion_query,response_msg )
  LassoAssertionQuery* assertion_query
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_assertion_query_add_attribute_request( assertion_query,format,name )
  LassoAssertionQuery* assertion_query
  string_non_null format
  string_non_null name
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoAssertionQueryRequestType
lasso_assertion_query_get_request_type( assertion_query )
  LassoAssertionQuery* assertion_query
  INIT:
    check_gobject((GObject*)assertion_query, lasso_assertion_query_get_type());

MODULE = Lasso	PACKAGE = Lasso::NameIdManagement	PREFIX = lasso_name_id_management_


LassoNameIdManagement*
lasso_name_id_management_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

LassoNameIdManagement*
lasso_name_id_management_new_from_dump( server,dump )
  LassoServer* server
  string_non_null dump
   CODE:
       RETVAL = (LassoNameIdManagement*)lasso_name_id_management_new_from_dump(server ,dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

char*
lasso_name_id_management_dump( name_id_management )
  LassoNameIdManagement* name_id_management
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());

lasso_error_t
lasso_name_id_management_init_request( name_id_management,remote_provider_id = NULL,new_name_id = NULL,http_method = LASSO_HTTP_METHOD_ANY )
  LassoNameIdManagement* name_id_management
  string_or_null remote_provider_id
  string_or_null new_name_id
  LassoHttpMethod http_method
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_id_management_build_request_msg( name_id_management )
  LassoNameIdManagement* name_id_management
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_id_management_process_request_msg( name_id_management,request_msg )
  LassoNameIdManagement* name_id_management
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_id_management_validate_request( name_id_management )
  LassoNameIdManagement* name_id_management
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_id_management_build_response_msg( name_id_management )
  LassoNameIdManagement* name_id_management
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_id_management_process_response_msg( name_id_management,response_msg )
  LassoNameIdManagement* name_id_management
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)name_id_management, lasso_name_id_management_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Logout	PREFIX = lasso_logout_


LassoLogout*
lasso_logout_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

LassoLogout*
lasso_logout_new_from_dump( server,dump )
  LassoServer* server
  string_non_null dump
   CODE:
       RETVAL = (LassoLogout*)lasso_logout_new_from_dump(server ,dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_logout_build_request_msg( logout )
  LassoLogout* logout
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_logout_build_response_msg( logout )
  LassoLogout* logout
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gchar*
lasso_logout_dump( logout )
  LassoLogout* logout
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());

gchar*
lasso_logout_get_next_providerID( logout )
  LassoLogout* logout
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());

lasso_error_t
lasso_logout_init_request( logout,remote_providerID = NULL,request_method = LASSO_HTTP_METHOD_ANY )
  LassoLogout* logout
  string_or_null remote_providerID
  LassoHttpMethod request_method
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_logout_process_request_msg( logout,request_msg )
  LassoLogout* logout
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_logout_process_response_msg( logout,response_msg )
  LassoLogout* logout
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_logout_reset_providerID_index( logout )
  LassoLogout* logout
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_logout_validate_request( logout )
  LassoLogout* logout
  INIT:
    check_gobject((GObject*)logout, lasso_logout_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Login	PREFIX = lasso_login_


LassoLogin*
lasso_login_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

LassoLogin*
lasso_login_new_from_dump( server,dump )
  LassoServer* server
  string_non_null dump
   CODE:
       RETVAL = (LassoLogin*)lasso_login_new_from_dump(server ,dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_login_accept_sso( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_build_artifact_msg( login,http_method )
  LassoLogin* login
  LassoHttpMethod http_method
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_build_assertion( login,authenticationMethod = NULL,authenticationInstant = NULL,reauthenticateOnOrAfter = NULL,notBefore = NULL,notOnOrAfter = NULL )
  LassoLogin* login
  string_or_null authenticationMethod
  string_or_null authenticationInstant
  string_or_null reauthenticateOnOrAfter
  string_or_null notBefore
  string_or_null notOnOrAfter
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_build_authn_request_msg( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_build_authn_response_msg( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_build_request_msg( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_build_response_msg( login,remote_providerID = NULL )
  LassoLogin* login
  string_or_null remote_providerID
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gchar*
lasso_login_dump( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());

lasso_error_t
lasso_login_init_authn_request( login,remote_providerID = NULL,http_method = LASSO_HTTP_METHOD_REDIRECT )
  LassoLogin* login
  string_or_null remote_providerID
  LassoHttpMethod http_method
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_init_request( login,response_msg,response_http_method = LASSO_HTTP_METHOD_REDIRECT )
  LassoLogin* login
  string_non_null response_msg
  LassoHttpMethod response_http_method
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_init_idp_initiated_authn_request( login,remote_providerID )
  LassoLogin* login
  string_non_null remote_providerID
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gboolean
lasso_login_must_ask_for_consent( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());

gboolean
lasso_login_must_authenticate( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());

lasso_error_t
lasso_login_process_authn_request_msg( login,authn_request_msg = NULL )
  LassoLogin* login
  string_or_null authn_request_msg
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_process_authn_response_msg( login,authn_response_msg )
  LassoLogin* login
  string_non_null authn_response_msg
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_process_request_msg( login,request_msg )
  LassoLogin* login
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_process_response_msg( login,response_msg )
  LassoLogin* login
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_validate_request_msg( login,authentication_result,is_consent_obtained )
  LassoLogin* login
  gboolean authentication_result
  gboolean is_consent_obtained
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_login_process_paos_response_msg( login,msg )
  LassoLogin* login
  string_non_null msg
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoNode*
lasso_login_get_assertion( login )
  LassoLogin* login
  INIT:
    check_gobject((GObject*)login, lasso_login_get_type());
  CLEANUP:
    lasso_unref(RETVAL);

LassoLoginProtocolProfile
protocolProfile(LassoLogin* obj, LassoLoginProtocolProfile value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->protocolProfile, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->protocolProfile;
        }
    OUTPUT:
        RETVAL

            

gchar*
assertionArtifact(LassoLogin* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->assertionArtifact, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->assertionArtifact;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::NameIdentifierMapping	PREFIX = lasso_name_identifier_mapping_


LassoNameIdentifierMapping*
lasso_name_identifier_mapping_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_name_identifier_mapping_build_request_msg( mapping )
  LassoNameIdentifierMapping* mapping
  INIT:
    check_gobject((GObject*)mapping, lasso_name_identifier_mapping_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_identifier_mapping_build_response_msg( mapping )
  LassoNameIdentifierMapping* mapping
  INIT:
    check_gobject((GObject*)mapping, lasso_name_identifier_mapping_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_identifier_mapping_init_request( mapping,targetNamespace,remote_providerID = NULL )
  LassoNameIdentifierMapping* mapping
  string_non_null targetNamespace
  string_or_null remote_providerID
  INIT:
    check_gobject((GObject*)mapping, lasso_name_identifier_mapping_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_identifier_mapping_process_request_msg( mapping,request_msg )
  LassoNameIdentifierMapping* mapping
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)mapping, lasso_name_identifier_mapping_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_identifier_mapping_process_response_msg( mapping,response_msg )
  LassoNameIdentifierMapping* mapping
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)mapping, lasso_name_identifier_mapping_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_identifier_mapping_validate_request( mapping )
  LassoNameIdentifierMapping* mapping
  INIT:
    check_gobject((GObject*)mapping, lasso_name_identifier_mapping_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gchar*
targetNameIdentifier(LassoNameIdentifierMapping* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->targetNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->targetNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::NameRegistration	PREFIX = lasso_name_registration_


LassoNameRegistration*
lasso_name_registration_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

LassoNameRegistration*
lasso_name_registration_new_from_dump( server,dump )
  LassoServer* server
  string_non_null dump
   CODE:
       RETVAL = (LassoNameRegistration*)lasso_name_registration_new_from_dump(server ,dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_name_registration_build_request_msg( name_registration )
  LassoNameRegistration* name_registration
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_registration_build_response_msg( name_registration )
  LassoNameRegistration* name_registration
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gchar*
lasso_name_registration_dump( name_registration )
  LassoNameRegistration* name_registration
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());

lasso_error_t
lasso_name_registration_init_request( name_registration,remote_providerID,http_method = LASSO_HTTP_METHOD_ANY )
  LassoNameRegistration* name_registration
  string_non_null remote_providerID
  LassoHttpMethod http_method
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_registration_process_request_msg( name_registration,request_msg )
  LassoNameRegistration* name_registration
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_registration_process_response_msg( name_registration,response_msg )
  LassoNameRegistration* name_registration
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_name_registration_validate_request( name_registration )
  LassoNameRegistration* name_registration
  INIT:
    check_gobject((GObject*)name_registration, lasso_name_registration_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoSamlNameIdentifier*
oldNameIdentifier(LassoNameRegistration* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->oldNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->oldNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Provider	PREFIX = lasso_provider_


LassoProvider*
lasso_provider_new( cls,role,metadata,public_key = NULL,ca_cert_chain = NULL )
  char *cls
  LassoProviderRole role
  string_non_null metadata
  string_or_null public_key
  string_or_null ca_cert_chain
  INIT:
    cls = NULL;
  C_ARGS:
    role, metadata, public_key, ca_cert_chain
  CLEANUP:
    lasso_unref(RETVAL);

LassoProvider*
lasso_provider_new_from_buffer( role,metadata,public_key = NULL,ca_cert_chain = NULL )
  LassoProviderRole role
  string_non_null metadata
  string_or_null public_key
  string_or_null ca_cert_chain
   CODE:
       RETVAL = (LassoProvider*)lasso_provider_new_from_buffer(role ,metadata ,public_key ,ca_cert_chain);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoProvider*
lasso_provider_new_from_dump( dump )
  string_non_null dump
   CODE:
       RETVAL = (LassoProvider*)lasso_provider_new_from_dump(dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2EncryptedElement*
lasso_provider_saml2_node_encrypt( provider,lasso_node )
  LassoProvider* provider
  LassoNode* lasso_node
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());
  CLEANUP:
    lasso_unref(RETVAL);

gchar*
lasso_provider_get_assertion_consumer_service_url( provider,service_id = NULL )
  LassoProvider* provider
  string_or_null service_id
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gchar*
lasso_provider_get_metadata_one( provider,name )
  LassoProvider* provider
  string_non_null name
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

GList_string
lasso_provider_get_metadata_list( provider,name )
  LassoProvider* provider
  string_non_null name
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

LassoHttpMethod
lasso_provider_get_first_http_method( provider,remote_provider,protocol_type )
  LassoProvider* provider
  LassoProvider* remote_provider
  LassoMdProtocolType protocol_type
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gboolean
lasso_provider_accept_http_method( provider,remote_provider,protocol_type,http_method,initiate_profile )
  LassoProvider* provider
  LassoProvider* remote_provider
  LassoMdProtocolType protocol_type
  LassoHttpMethod http_method
  gboolean initiate_profile
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gboolean
lasso_provider_has_protocol_profile( provider,protocol_type,protocol_profile )
  LassoProvider* provider
  LassoMdProtocolType protocol_type
  string_non_null protocol_profile
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gchar*
lasso_provider_get_base64_succinct_id( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

xmlNode*
lasso_provider_get_organization( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

LassoProtocolConformance
lasso_provider_get_protocol_conformance( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

void
lasso_provider_set_encryption_mode( provider,encryption_mode )
  LassoProvider* provider
  LassoEncryptionMode encryption_mode
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

LassoEncryptionMode
lasso_provider_get_encryption_mode( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

void
lasso_provider_set_encryption_sym_key_type( provider,encryption_sym_key_type )
  LassoProvider* provider
  LassoEncryptionSymKeyType encryption_sym_key_type
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gchar*
lasso_provider_get_default_name_id_format( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

const char*
lasso_provider_get_sp_name_qualifier( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

lasso_error_t
lasso_provider_verify_single_node_signature( provider,node,id_attr_name )
  LassoProvider* provider
  LassoNode* node
  string_non_null id_attr_name
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

GList_gobject
lasso_provider_get_idp_supported_attributes( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

char*
lasso_provider_get_valid_until( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

char*
lasso_provider_get_cache_duration( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

char*
lasso_provider_get_metadata_one_for_role( provider,role,name )
  LassoProvider* provider
  LassoProviderRole role
  string_non_null name
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

GList_string
lasso_provider_get_metadata_list_for_role( provider,role,name )
  LassoProvider* provider
  LassoProviderRole role
  string_non_null name
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

GList_string
lasso_provider_get_metadata_keys_for_role( provider,role )
  LassoProvider* provider
  LassoProviderRole role
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

LassoProviderRole
lasso_provider_get_roles( provider )
  LassoProvider* provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gboolean
lasso_provider_match_conformance( provider,another_provider )
  LassoProvider* provider
  LassoProvider* another_provider
  INIT:
    check_gobject((GObject*)provider, lasso_provider_get_type());

gchar*
ProviderID(LassoProvider* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoProviderRole
role(LassoProvider* obj, LassoProviderRole value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->role, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->role;
        }
    OUTPUT:
        RETVAL

            

char*
metadata_filename(LassoProvider* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->metadata_filename, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->metadata_filename;
        }
    OUTPUT:
        RETVAL

            

gchar*
public_key(LassoProvider* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->public_key, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->public_key;
        }
    OUTPUT:
        RETVAL

            

gchar*
ca_cert_chain(LassoProvider* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ca_cert_chain, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ca_cert_chain;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Server	PREFIX = lasso_server_


LassoServer*
lasso_server_new( cls,metadata = NULL,private_key = NULL,private_key_password = NULL,certificate = NULL )
  char *cls
  string_or_null metadata
  string_or_null private_key
  string_or_null private_key_password
  string_or_null certificate
  INIT:
    cls = NULL;
  C_ARGS:
    metadata, private_key, private_key_password, certificate
  CLEANUP:
    lasso_unref(RETVAL);

LassoServer*
lasso_server_new_from_buffers( metadata,private_key_content = NULL,private_key_password = NULL,certificate_content = NULL )
  string_non_null metadata
  string_or_null private_key_content
  string_or_null private_key_password
  string_or_null certificate_content
   CODE:
       RETVAL = (LassoServer*)lasso_server_new_from_buffers(metadata ,private_key_content ,private_key_password ,certificate_content);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoServer*
lasso_server_new_from_dump( dump )
  string_non_null dump
   CODE:
       RETVAL = (LassoServer*)lasso_server_new_from_dump(dump);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_server_saml2_assertion_setup_signature( server,saml2_assertion )
  LassoServer* server
  LassoSaml2Assertion* saml2_assertion
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_server_add_provider( server,role,metadata,public_key = NULL,ca_cert_chain = NULL )
  LassoServer* server
  LassoProviderRole role
  string_non_null metadata
  string_or_null public_key
  string_or_null ca_cert_chain
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_server_add_provider_from_buffer( server,role,metadata,public_key = NULL,ca_cert_chain = NULL )
  LassoServer* server
  LassoProviderRole role
  string_non_null metadata
  string_or_null public_key
  string_or_null ca_cert_chain
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

gchar*
lasso_server_dump( server )
  LassoServer* server
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());

LassoProvider*
lasso_server_get_provider( server,providerID )
  LassoServer* server
  string_non_null providerID
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());

lasso_error_t
lasso_server_set_encryption_private_key( server,filename_or_buffer = NULL )
  LassoServer* server
  string_or_null filename_or_buffer
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_server_load_affiliation( server,filename )
  LassoServer* server
  string_non_null filename
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_server_set_encryption_private_key_with_password( server,filename_or_buffer = NULL,password = NULL )
  LassoServer* server
  string_or_null filename_or_buffer
  string_or_null password
  INIT:
    check_gobject((GObject*)server, lasso_server_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

HV*
providers(LassoServer* obj, ...)
    PROTOTYPE:
        $;\%
    CODE:
        if (items > 1) { /* setter */
            if (SvTYPE(ST(1)) != SVt_RV || ! SvTYPE(SvRV(ST(1))) != SVt_PVHV) {
                sv_dump(ST(1));
                croak("Lasso::Server::providers takes a reference to a hash as argument");
            }
            set_hash_of_objects(&obj->providers, (HV*)SvRV(ST(1)));
        }
        RETVAL = get_hash_of_objects(obj->providers);
        sv_2mortal((SV*)RETVAL);
    OUTPUT:
        RETVAL


gchar*
private_key(LassoServer* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->private_key, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->private_key;
        }
    OUTPUT:
        RETVAL

            

gchar*
private_key_password(LassoServer* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->private_key_password, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->private_key_password;
        }
    OUTPUT:
        RETVAL

            

gchar*
certificate(LassoServer* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->certificate, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->certificate;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureMethod
signature_method(LassoServer* obj, LassoSignatureMethod value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->signature_method, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->signature_method;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Lecp	PREFIX = lasso_lecp_


LassoLecp*
lasso_lecp_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_lecp_build_authn_request_envelope_msg( lecp )
  LassoLecp* lecp
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_build_authn_request_msg( lecp )
  LassoLecp* lecp
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_build_authn_response_msg( lecp )
  LassoLecp* lecp
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_build_authn_response_envelope_msg( lecp )
  LassoLecp* lecp
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_init_authn_request( lecp,remote_providerID = NULL )
  LassoLecp* lecp
  string_or_null remote_providerID
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_process_authn_request_msg( lecp,authn_request_msg )
  LassoLecp* lecp
  string_non_null authn_request_msg
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_process_authn_request_envelope_msg( lecp,request_msg )
  LassoLecp* lecp
  string_non_null request_msg
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_lecp_process_authn_response_envelope_msg( lecp,response_msg )
  LassoLecp* lecp
  string_non_null response_msg
  INIT:
    check_gobject((GObject*)lecp, lasso_lecp_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoLibAuthnRequestEnvelope*
authnRequestEnvelope(LassoLecp* obj, LassoLibAuthnRequestEnvelope* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->authnRequestEnvelope, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->authnRequestEnvelope;
        }
    OUTPUT:
        RETVAL

            

LassoLibAuthnResponseEnvelope*
authnResponseEnvelope(LassoLecp* obj, LassoLibAuthnResponseEnvelope* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->authnResponseEnvelope, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->authnResponseEnvelope;
        }
    OUTPUT:
        RETVAL

            

char*
assertionConsumerServiceURL(LassoLecp* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->assertionConsumerServiceURL, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->assertionConsumerServiceURL;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Defederation	PREFIX = lasso_defederation_


LassoDefederation*
lasso_defederation_new( cls,server )
  char *cls
  LassoServer* server
  INIT:
    cls = NULL;
  C_ARGS:
    server
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_defederation_build_notification_msg( defederation )
  LassoDefederation* defederation
  INIT:
    check_gobject((GObject*)defederation, lasso_defederation_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_defederation_init_notification( defederation,remote_providerID = NULL,http_method = LASSO_HTTP_METHOD_ANY )
  LassoDefederation* defederation
  string_or_null remote_providerID
  LassoHttpMethod http_method
  INIT:
    check_gobject((GObject*)defederation, lasso_defederation_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_defederation_process_notification_msg( defederation,notification_msg )
  LassoDefederation* defederation
  string_non_null notification_msg
  INIT:
    check_gobject((GObject*)defederation, lasso_defederation_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

lasso_error_t
lasso_defederation_validate_notification( defederation )
  LassoDefederation* defederation
  INIT:
    check_gobject((GObject*)defederation, lasso_defederation_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::MiscTextNode	PREFIX = lasso_misc_text_node_


LassoNode*
lasso_misc_text_node_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoMiscTextNode*
lasso_misc_text_node_new_with_string( content )
  string_non_null content
   CODE:
       RETVAL = (LassoMiscTextNode*)lasso_misc_text_node_new_with_string(content);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoMiscTextNode*
lasso_misc_text_node_new_with_xml_node( xml_node )
  xmlNode* xml_node
   CODE:
       RETVAL = (LassoMiscTextNode*)lasso_misc_text_node_new_with_xml_node(xml_node);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_release_xml_node(xml_node)
    lasso_unref(RETVAL);

void
lasso_misc_text_node_set_xml_content( misc_text_node,node )
  LassoMiscTextNode* misc_text_node
  xmlNode* node
  INIT:
    check_gobject((GObject*)misc_text_node, lasso_misc_text_node_get_type());
  CLEANUP:
    lasso_release_xml_node(node)

xmlNode*
lasso_misc_text_node_get_xml_content( misc_text_node )
  LassoMiscTextNode* misc_text_node
  INIT:
    check_gobject((GObject*)misc_text_node, lasso_misc_text_node_get_type());

char*
content(LassoMiscTextNode* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->content, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->content;
        }
    OUTPUT:
        RETVAL

            

char*
name(LassoMiscTextNode* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->name, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->name;
        }
    OUTPUT:
        RETVAL

            

char*
ns_href(LassoMiscTextNode* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ns_href, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ns_href;
        }
    OUTPUT:
        RETVAL

            

char*
ns_prefix(LassoMiscTextNode* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ns_prefix, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ns_prefix;
        }
    OUTPUT:
        RETVAL

            

gboolean
text_child(LassoMiscTextNode* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->text_child, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->text_child;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAuthorityBinding	PREFIX = lasso_saml_authority_binding_


LassoNode*
lasso_saml_authority_binding_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
AuthorityKind(LassoSamlAuthorityBinding* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthorityKind, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthorityKind;
        }
    OUTPUT:
        RETVAL

            

char*
Location(LassoSamlAuthorityBinding* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Location, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Location;
        }
    OUTPUT:
        RETVAL

            

char*
Binding(LassoSamlAuthorityBinding* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Binding, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Binding;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlNameIdentifier	PREFIX = lasso_saml_name_identifier_


LassoSamlNameIdentifier*
lasso_saml_name_identifier_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlNameIdentifier*
lasso_saml_name_identifier_new_from_xmlNode( xmlnode )
  xmlNode* xmlnode
   CODE:
       RETVAL = (LassoSamlNameIdentifier*)lasso_saml_name_identifier_new_from_xmlNode(xmlnode);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_release_xml_node(xmlnode)
    lasso_unref(RETVAL);

char*
NameQualifier(LassoSamlNameIdentifier* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NameQualifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameQualifier;
        }
    OUTPUT:
        RETVAL

            

char*
Format(LassoSamlNameIdentifier* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Format, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Format;
        }
    OUTPUT:
        RETVAL

            

char*
content(LassoSamlNameIdentifier* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->content, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->content;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAttributeDesignator	PREFIX = lasso_saml_attribute_designator_


LassoNode*
lasso_saml_attribute_designator_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
AttributeName(LassoSamlAttributeDesignator* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AttributeName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeName;
        }
    OUTPUT:
        RETVAL

            

char*
AttributeNamespace(LassoSamlAttributeDesignator* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AttributeNamespace, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeNamespace;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAttribute	PREFIX = lasso_saml_attribute_


LassoSamlAttribute*
lasso_saml_attribute_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

gchar*
attributeName(LassoSamlAttribute* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->attributeName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->attributeName;
        }
    OUTPUT:
        RETVAL

            

gchar*
attributeNameSpace(LassoSamlAttribute* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->attributeNameSpace, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->attributeNameSpace;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AttributeValue(LassoSamlAttribute* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AttributeValue);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AttributeValue);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AttributeValue, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeValue;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::DsRsaKeyValue	PREFIX = lasso_ds_rsa_key_value_


LassoDsRsaKeyValue*
lasso_ds_rsa_key_value_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
Modulus(LassoDsRsaKeyValue* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Modulus, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Modulus;
        }
    OUTPUT:
        RETVAL

            

char*
Exponent(LassoDsRsaKeyValue* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Exponent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Exponent;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibAuthnResponseEnvelope	PREFIX = lasso_lib_authn_response_envelope_


LassoLibAuthnResponseEnvelope*
lasso_lib_authn_response_envelope_new( cls,response,assertionConsumerServiceURL )
  char *cls
  LassoLibAuthnResponse* response
  string_non_null assertionConsumerServiceURL
  INIT:
    cls = NULL;
  C_ARGS:
    response, assertionConsumerServiceURL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibAuthnResponseEnvelope* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

LassoLibAuthnResponse*
AuthnResponse(LassoLibAuthnResponseEnvelope* obj, LassoLibAuthnResponse* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->AuthnResponse, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnResponse;
        }
    OUTPUT:
        RETVAL

            

char*
AssertionConsumerServiceURL(LassoLibAuthnResponseEnvelope* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionConsumerServiceURL, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionConsumerServiceURL;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlSubject	PREFIX = lasso_saml_subject_


LassoNode*
lasso_saml_subject_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlNameIdentifier*
NameIdentifier(LassoSamlSubject* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIdentifier;
        }
    OUTPUT:
        RETVAL

            

LassoSamlSubjectConfirmation*
SubjectConfirmation(LassoSamlSubject* obj, LassoSamlSubjectConfirmation* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SubjectConfirmation, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectConfirmation;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedNameIdentifier(LassoSamlSubject* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibSubject	PREFIX = lasso_lib_subject_


LassoLibSubject*
lasso_lib_subject_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlNameIdentifier*
IDPProvidedNameIdentifier(LassoLibSubject* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPProvidedNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPProvidedNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAttributeValue	PREFIX = lasso_saml_attribute_value_


LassoSamlAttributeValue*
lasso_saml_attribute_value_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
any(LassoSamlAttributeValue* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->any);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->any);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->any, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->any;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlStatementAbstract	PREFIX = lasso_saml_statement_abstract_


MODULE = Lasso	PACKAGE = Lasso::SamlSubjectStatementAbstract	PREFIX = lasso_saml_subject_statement_abstract_


LassoSamlSubject*
Subject(LassoSamlSubjectStatementAbstract* obj, LassoSamlSubject* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Subject, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Subject;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAttributeStatement	PREFIX = lasso_saml_attribute_statement_


LassoSamlAttributeStatement*
lasso_saml_attribute_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Attribute(LassoSamlAttributeStatement* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Attribute);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Attribute);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->Attribute, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Attribute;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::DsKeyValue	PREFIX = lasso_ds_key_value_


LassoDsKeyValue*
lasso_ds_key_value_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoDsRsaKeyValue*
RSAKeyValue(LassoDsKeyValue* obj, LassoDsRsaKeyValue* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->RSAKeyValue, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RSAKeyValue;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::DsKeyInfo	PREFIX = lasso_ds_key_info_


LassoDsKeyInfo*
lasso_ds_key_info_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoDsKeyValue*
KeyValue(LassoDsKeyInfo* obj, LassoDsKeyValue* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->KeyValue, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->KeyValue;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibIDPEntry	PREFIX = lasso_lib_idp_entry_


LassoNode*
lasso_lib_idp_entry_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
ProviderID(LassoLibIDPEntry* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderName(LassoLibIDPEntry* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderName;
        }
    OUTPUT:
        RETVAL

            

char*
Loc(LassoLibIDPEntry* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Loc, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Loc;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlpStatusCode	PREFIX = lasso_samlp_status_code_


LassoSamlpStatusCode*
lasso_samlp_status_code_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlpStatusCode*
StatusCode(LassoSamlpStatusCode* obj, LassoSamlpStatusCode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->StatusCode, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusCode;
        }
    OUTPUT:
        RETVAL

            

char*
Value(LassoSamlpStatusCode* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Value, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Value;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlpRequestAbstract	PREFIX = lasso_samlp_request_abstract_


GList_string
RespondWith(LassoSamlpRequestAbstract* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->RespondWith);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->RespondWith);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->RespondWith, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->RespondWith;
        }
    OUTPUT:
        RETVAL

            

char*
RequestID(LassoSamlpRequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RequestID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RequestID;
        }
    OUTPUT:
        RETVAL

            

int
MajorVersion(LassoSamlpRequestAbstract* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->MajorVersion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->MajorVersion;
        }
    OUTPUT:
        RETVAL

            

int
MinorVersion(LassoSamlpRequestAbstract* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->MinorVersion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->MinorVersion;
        }
    OUTPUT:
        RETVAL

            

char*
IssueInstant(LassoSamlpRequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IssueInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IssueInstant;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureType
sign_type(LassoSamlpRequestAbstract* obj, LassoSignatureType value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->sign_type, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->sign_type;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureMethod
sign_method(LassoSamlpRequestAbstract* obj, LassoSignatureMethod value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->sign_method, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->sign_method;
        }
    OUTPUT:
        RETVAL

            

char*
private_key_file(LassoSamlpRequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->private_key_file, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->private_key_file;
        }
    OUTPUT:
        RETVAL

            

char*
certificate_file(LassoSamlpRequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->certificate_file, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->certificate_file;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibNameIdentifierMappingRequest	PREFIX = lasso_lib_name_identifier_mapping_request_


LassoNode*
lasso_lib_name_identifier_mapping_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_name_identifier_mapping_request_new_full( providerID,nameIdentifier,targetNamespace,sign_type,sign_method )
  string_non_null providerID
  LassoSamlNameIdentifier* nameIdentifier
  string_non_null targetNamespace
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_name_identifier_mapping_request_new_full(providerID ,nameIdentifier ,targetNamespace ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibNameIdentifierMappingRequest* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibNameIdentifierMappingRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
NameIdentifier(LassoLibNameIdentifierMappingRequest* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIdentifier;
        }
    OUTPUT:
        RETVAL

            

char*
TargetNamespace(LassoLibNameIdentifierMappingRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->TargetNamespace, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->TargetNamespace;
        }
    OUTPUT:
        RETVAL

            

char*
consent(LassoLibNameIdentifierMappingRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->consent;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibFederationTerminationNotification	PREFIX = lasso_lib_federation_termination_notification_


LassoNode*
lasso_lib_federation_termination_notification_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_federation_termination_notification_new_full( providerID,nameIdentifier,sign_type,sign_method )
  string_non_null providerID
  LassoSamlNameIdentifier* nameIdentifier
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_federation_termination_notification_new_full(providerID ,nameIdentifier ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibFederationTerminationNotification* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibFederationTerminationNotification* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
NameIdentifier(LassoLibFederationTerminationNotification* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIdentifier;
        }
    OUTPUT:
        RETVAL

            

char*
consent(LassoLibFederationTerminationNotification* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->consent;
        }
    OUTPUT:
        RETVAL

            

char*
RelayState(LassoLibFederationTerminationNotification* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RelayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RelayState;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibRegisterNameIdentifierRequest	PREFIX = lasso_lib_register_name_identifier_request_


LassoNode*
lasso_lib_register_name_identifier_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_register_name_identifier_request_new_full( providerID,idpNameIdentifier,spNameIdentifier,oldNameIdentifier,sign_type,sign_method )
  string_non_null providerID
  LassoSamlNameIdentifier* idpNameIdentifier
  LassoSamlNameIdentifier* spNameIdentifier
  LassoSamlNameIdentifier* oldNameIdentifier
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_register_name_identifier_request_new_full(providerID ,idpNameIdentifier ,spNameIdentifier ,oldNameIdentifier ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibRegisterNameIdentifierRequest* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibRegisterNameIdentifierRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
IDPProvidedNameIdentifier(LassoLibRegisterNameIdentifierRequest* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPProvidedNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPProvidedNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
SPProvidedNameIdentifier(LassoLibRegisterNameIdentifierRequest* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SPProvidedNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SPProvidedNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
OldProvidedNameIdentifier(LassoLibRegisterNameIdentifierRequest* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->OldProvidedNameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->OldProvidedNameIdentifier;
        }
    OUTPUT:
        RETVAL

            

char*
RelayState(LassoLibRegisterNameIdentifierRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RelayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RelayState;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibAuthnRequest	PREFIX = lasso_lib_authn_request_


LassoLibAuthnRequest*
lasso_lib_authn_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibAuthnRequest* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

char*
AffiliationID(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AffiliationID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AffiliationID;
        }
    OUTPUT:
        RETVAL

            

char*
NameIDPolicy(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NameIDPolicy, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIDPolicy;
        }
    OUTPUT:
        RETVAL

            

gboolean
ForceAuthn(LassoLibAuthnRequest* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->ForceAuthn, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ForceAuthn;
        }
    OUTPUT:
        RETVAL

            

gboolean
IsPassive(LassoLibAuthnRequest* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->IsPassive, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IsPassive;
        }
    OUTPUT:
        RETVAL

            

char*
ProtocolProfile(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProtocolProfile, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProtocolProfile;
        }
    OUTPUT:
        RETVAL

            

char*
AssertionConsumerServiceID(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionConsumerServiceID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionConsumerServiceID;
        }
    OUTPUT:
        RETVAL

            

LassoLibRequestAuthnContext*
RequestAuthnContext(LassoLibAuthnRequest* obj, LassoLibRequestAuthnContext* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->RequestAuthnContext, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RequestAuthnContext;
        }
    OUTPUT:
        RETVAL

            

char*
RelayState(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RelayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RelayState;
        }
    OUTPUT:
        RETVAL

            

LassoLibScoping*
Scoping(LassoLibAuthnRequest* obj, LassoLibScoping* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Scoping, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Scoping;
        }
    OUTPUT:
        RETVAL

            

char*
consent(LassoLibAuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->consent;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibAuthnContext	PREFIX = lasso_lib_authn_context_


LassoNode*
lasso_lib_authn_context_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
AuthnContextClassRef(LassoLibAuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthnContextClassRef, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextClassRef;
        }
    OUTPUT:
        RETVAL

            

char*
AuthnContextStatementRef(LassoLibAuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthnContextStatementRef, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextStatementRef;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibScoping	PREFIX = lasso_lib_scoping_


LassoLibScoping*
lasso_lib_scoping_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

int
ProxyCount(LassoLibScoping* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->ProxyCount, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProxyCount;
        }
    OUTPUT:
        RETVAL

            

LassoLibIDPList*
IDPList(LassoLibScoping* obj, LassoLibIDPList* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPList, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPList;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibIDPEntries	PREFIX = lasso_lib_idp_entries_


LassoNode*
lasso_lib_idp_entries_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
IDPEntry(LassoLibIDPEntries* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->IDPEntry);
            for (; i < items; i++) {
                LassoLibIDPEntry* data;
                data = (LassoLibIDPEntry*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->IDPEntry);
                    croak("an element cannot be converted to an LassoLibIDPEntry*");
                }
                lasso_list_add_gobject(obj->IDPEntry, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPEntry;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibLogoutRequest	PREFIX = lasso_lib_logout_request_


LassoNode*
lasso_lib_logout_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_logout_request_new_full( providerID,nameIdentifier,sign_type,sign_method )
  string_non_null providerID
  LassoSamlNameIdentifier* nameIdentifier
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_logout_request_new_full(providerID ,nameIdentifier ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibLogoutRequest* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibLogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
NameIdentifier(LassoLibLogoutRequest* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIdentifier;
        }
    OUTPUT:
        RETVAL

            

char*
SessionIndex(LassoLibLogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SessionIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SessionIndex;
        }
    OUTPUT:
        RETVAL

            

char*
RelayState(LassoLibLogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RelayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RelayState;
        }
    OUTPUT:
        RETVAL

            

char*
consent(LassoLibLogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->consent;
        }
    OUTPUT:
        RETVAL

            

char*
NotOnOrAfter(LassoLibLogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibIDPList	PREFIX = lasso_lib_idp_list_


LassoNode*
lasso_lib_idp_list_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoLibIDPEntries*
IDPEntries(LassoLibIDPList* obj, LassoLibIDPEntries* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPEntries, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPEntries;
        }
    OUTPUT:
        RETVAL

            

char*
GetComplete(LassoLibIDPList* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->GetComplete, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->GetComplete;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlConditionAbstract	PREFIX = lasso_saml_condition_abstract_


MODULE = Lasso	PACKAGE = Lasso::SamlAudienceRestrictionCondition	PREFIX = lasso_saml_audience_restriction_condition_


LassoSamlAudienceRestrictionCondition*
lasso_saml_audience_restriction_condition_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlAudienceRestrictionCondition*
lasso_saml_audience_restriction_condition_new_full( audience )
  string_non_null audience
   CODE:
       RETVAL = (LassoSamlAudienceRestrictionCondition*)lasso_saml_audience_restriction_condition_new_full(audience);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_string
Audience(LassoSamlAudienceRestrictionCondition* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->Audience);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->Audience);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->Audience, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Audience;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibAuthnRequestEnvelope	PREFIX = lasso_lib_authn_request_envelope_


LassoLibAuthnRequestEnvelope*
lasso_lib_authn_request_envelope_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoLibAuthnRequestEnvelope*
lasso_lib_authn_request_envelope_new_full( authnRequest,providerID,assertionConsumerServiceURL )
  LassoLibAuthnRequest* authnRequest
  string_non_null providerID
  string_non_null assertionConsumerServiceURL
   CODE:
       RETVAL = (LassoLibAuthnRequestEnvelope*)lasso_lib_authn_request_envelope_new_full(authnRequest ,providerID ,assertionConsumerServiceURL);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibAuthnRequestEnvelope* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

LassoLibAuthnRequest*
AuthnRequest(LassoLibAuthnRequestEnvelope* obj, LassoLibAuthnRequest* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->AuthnRequest, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnRequest;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibAuthnRequestEnvelope* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderName(LassoLibAuthnRequestEnvelope* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderName;
        }
    OUTPUT:
        RETVAL

            

char*
AssertionConsumerServiceURL(LassoLibAuthnRequestEnvelope* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionConsumerServiceURL, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionConsumerServiceURL;
        }
    OUTPUT:
        RETVAL

            

LassoLibIDPList*
IDPList(LassoLibAuthnRequestEnvelope* obj, LassoLibIDPList* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPList, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPList;
        }
    OUTPUT:
        RETVAL

            

gboolean
IsPassive(LassoLibAuthnRequestEnvelope* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->IsPassive, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IsPassive;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibRequestAuthnContext	PREFIX = lasso_lib_request_authn_context_


LassoLibRequestAuthnContext*
lasso_lib_request_authn_context_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_string
AuthnContextClassRef(LassoLibRequestAuthnContext* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->AuthnContextClassRef);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->AuthnContextClassRef);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->AuthnContextClassRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextClassRef;
        }
    OUTPUT:
        RETVAL

            

GList_string
AuthnContextStatementRef(LassoLibRequestAuthnContext* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->AuthnContextStatementRef);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->AuthnContextStatementRef);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->AuthnContextStatementRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextStatementRef;
        }
    OUTPUT:
        RETVAL

            

char*
AuthnContextComparison(LassoLibRequestAuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthnContextComparison, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextComparison;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAdvice	PREFIX = lasso_saml_advice_


LassoNode*
lasso_saml_advice_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
AssertionIDReference(LassoSamlAdvice* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AssertionIDReference);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AssertionIDReference);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AssertionIDReference, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionIDReference;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
Assertion(LassoSamlAdvice* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Assertion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Assertion;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAssertion	PREFIX = lasso_saml_assertion_


LassoSamlAssertion*
lasso_saml_assertion_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlConditions*
Conditions(LassoSamlAssertion* obj, LassoSamlConditions* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Conditions, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Conditions;
        }
    OUTPUT:
        RETVAL

            

LassoSamlAdvice*
Advice(LassoSamlAssertion* obj, LassoSamlAdvice* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Advice, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Advice;
        }
    OUTPUT:
        RETVAL

            

LassoSamlSubjectStatement*
SubjectStatement(LassoSamlAssertion* obj, LassoSamlSubjectStatement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SubjectStatement, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectStatement;
        }
    OUTPUT:
        RETVAL

            

LassoSamlAuthenticationStatement*
AuthenticationStatement(LassoSamlAssertion* obj, LassoSamlAuthenticationStatement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->AuthenticationStatement, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthenticationStatement;
        }
    OUTPUT:
        RETVAL

            

LassoSamlAttributeStatement*
AttributeStatement(LassoSamlAssertion* obj, LassoSamlAttributeStatement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->AttributeStatement, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeStatement;
        }
    OUTPUT:
        RETVAL

            

int
MajorVersion(LassoSamlAssertion* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->MajorVersion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->MajorVersion;
        }
    OUTPUT:
        RETVAL

            

int
MinorVersion(LassoSamlAssertion* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->MinorVersion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->MinorVersion;
        }
    OUTPUT:
        RETVAL

            

char*
AssertionID(LassoSamlAssertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionID;
        }
    OUTPUT:
        RETVAL

            

char*
Issuer(LassoSamlAssertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Issuer, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Issuer;
        }
    OUTPUT:
        RETVAL

            

char*
IssueInstant(LassoSamlAssertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IssueInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IssueInstant;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureType
sign_type(LassoSamlAssertion* obj, LassoSignatureType value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->sign_type, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->sign_type;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureMethod
sign_method(LassoSamlAssertion* obj, LassoSignatureMethod value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->sign_method, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->sign_method;
        }
    OUTPUT:
        RETVAL

            

char*
private_key_file(LassoSamlAssertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->private_key_file, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->private_key_file;
        }
    OUTPUT:
        RETVAL

            

char*
certificate_file(LassoSamlAssertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->certificate_file, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->certificate_file;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibAssertion	PREFIX = lasso_lib_assertion_


LassoLibAssertion*
lasso_lib_assertion_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoLibAssertion*
lasso_lib_assertion_new_full( issuer,requestID = NULL,audience = NULL,notBefore,notOnOrAfter )
  string_non_null issuer
  string_or_null requestID
  string_or_null audience
  string_non_null notBefore
  string_non_null notOnOrAfter
   CODE:
       RETVAL = (LassoLibAssertion*)lasso_lib_assertion_new_full(issuer ,requestID ,audience ,notBefore ,notOnOrAfter);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

char*
InResponseTo(LassoLibAssertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->InResponseTo, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->InResponseTo;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlConditions	PREFIX = lasso_saml_conditions_


LassoSamlConditions*
lasso_saml_conditions_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Condition(LassoSamlConditions* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Condition);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Condition);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->Condition, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Condition;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AudienceRestrictionCondition(LassoSamlConditions* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AudienceRestrictionCondition);
            for (; i < items; i++) {
                LassoSamlAudienceRestrictionCondition* data;
                data = (LassoSamlAudienceRestrictionCondition*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AudienceRestrictionCondition);
                    croak("an element cannot be converted to an LassoSamlAudienceRestrictionCondition*");
                }
                lasso_list_add_gobject(obj->AudienceRestrictionCondition, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AudienceRestrictionCondition;
        }
    OUTPUT:
        RETVAL

            

char*
NotBefore(LassoSamlConditions* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotBefore, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotBefore;
        }
    OUTPUT:
        RETVAL

            

char*
NotOnOrAfter(LassoSamlConditions* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlSubjectStatement	PREFIX = lasso_saml_subject_statement_


LassoNode*
lasso_saml_subject_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::SamlpRequest	PREFIX = lasso_samlp_request_


LassoNode*
lasso_samlp_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
AssertionArtifact(LassoSamlpRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionArtifact, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionArtifact;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlSubjectConfirmation	PREFIX = lasso_saml_subject_confirmation_


LassoSamlSubjectConfirmation*
lasso_saml_subject_confirmation_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_string
ConfirmationMethod(LassoSamlSubjectConfirmation* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->ConfirmationMethod);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->ConfirmationMethod);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->ConfirmationMethod, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->ConfirmationMethod;
        }
    OUTPUT:
        RETVAL

            

char*
SubjectConfirmationData(LassoSamlSubjectConfirmation* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SubjectConfirmationData, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectConfirmationData;
        }
    OUTPUT:
        RETVAL

            

LassoDsKeyInfo*
KeyInfo(LassoSamlSubjectConfirmation* obj, LassoDsKeyInfo* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->KeyInfo, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->KeyInfo;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlpStatus	PREFIX = lasso_samlp_status_


LassoSamlpStatus*
lasso_samlp_status_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlpStatusCode*
StatusCode(LassoSamlpStatus* obj, LassoSamlpStatusCode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->StatusCode, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusCode;
        }
    OUTPUT:
        RETVAL

            

char*
StatusMessage(LassoSamlpStatus* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->StatusMessage, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusMessage;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlAuthenticationStatement	PREFIX = lasso_saml_authentication_statement_


LassoNode*
lasso_saml_authentication_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlSubjectLocality*
SubjectLocality(LassoSamlAuthenticationStatement* obj, LassoSamlSubjectLocality* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SubjectLocality, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectLocality;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AuthorityBinding(LassoSamlAuthenticationStatement* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AuthorityBinding);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AuthorityBinding);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AuthorityBinding, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthorityBinding;
        }
    OUTPUT:
        RETVAL

            

char*
AuthenticationMethod(LassoSamlAuthenticationStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthenticationMethod, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthenticationMethod;
        }
    OUTPUT:
        RETVAL

            

char*
AuthenticationInstant(LassoSamlAuthenticationStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthenticationInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthenticationInstant;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibAuthenticationStatement	PREFIX = lasso_lib_authentication_statement_


LassoLibAuthenticationStatement*
lasso_lib_authentication_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoLibAuthenticationStatement*
lasso_lib_authentication_statement_new_full( authenticationMethod,authenticationInstant = NULL,reauthenticateOnOrAfter = NULL,sp_identifier,idp_identifier )
  string_non_null authenticationMethod
  string_or_null authenticationInstant
  string_or_null reauthenticateOnOrAfter
  LassoSamlNameIdentifier* sp_identifier
  LassoSamlNameIdentifier* idp_identifier
   CODE:
       RETVAL = (LassoLibAuthenticationStatement*)lasso_lib_authentication_statement_new_full(authenticationMethod ,authenticationInstant ,reauthenticateOnOrAfter ,sp_identifier ,idp_identifier);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoLibAuthnContext*
AuthnContext(LassoLibAuthenticationStatement* obj, LassoLibAuthnContext* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->AuthnContext, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContext;
        }
    OUTPUT:
        RETVAL

            

char*
ReauthenticateOnOrAfter(LassoLibAuthenticationStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ReauthenticateOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ReauthenticateOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

char*
SessionIndex(LassoLibAuthenticationStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SessionIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SessionIndex;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlSubjectLocality	PREFIX = lasso_saml_subject_locality_


LassoNode*
lasso_saml_subject_locality_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
IPAddress(LassoSamlSubjectLocality* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IPAddress, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IPAddress;
        }
    OUTPUT:
        RETVAL

            

char*
DNSAddress(LassoSamlSubjectLocality* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->DNSAddress, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->DNSAddress;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlpResponseAbstract	PREFIX = lasso_samlp_response_abstract_


void
lasso_samlp_response_abstract_fill( response,InResponseTo,Recipient )
  LassoSamlpResponseAbstract* response
  string_non_null InResponseTo
  string_non_null Recipient
  INIT:
    check_gobject((GObject*)response, lasso_samlp_response_abstract_get_type());

char*
ResponseID(LassoSamlpResponseAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ResponseID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ResponseID;
        }
    OUTPUT:
        RETVAL

            

char*
InResponseTo(LassoSamlpResponseAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->InResponseTo, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->InResponseTo;
        }
    OUTPUT:
        RETVAL

            

int
MajorVersion(LassoSamlpResponseAbstract* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->MajorVersion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->MajorVersion;
        }
    OUTPUT:
        RETVAL

            

int
MinorVersion(LassoSamlpResponseAbstract* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->MinorVersion, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->MinorVersion;
        }
    OUTPUT:
        RETVAL

            

char*
IssueInstant(LassoSamlpResponseAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IssueInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IssueInstant;
        }
    OUTPUT:
        RETVAL

            

char*
Recipient(LassoSamlpResponseAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Recipient, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Recipient;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureType
sign_type(LassoSamlpResponseAbstract* obj, LassoSignatureType value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->sign_type, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->sign_type;
        }
    OUTPUT:
        RETVAL

            

LassoSignatureMethod
sign_method(LassoSamlpResponseAbstract* obj, LassoSignatureMethod value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->sign_method, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->sign_method;
        }
    OUTPUT:
        RETVAL

            

char*
private_key_file(LassoSamlpResponseAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->private_key_file, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->private_key_file;
        }
    OUTPUT:
        RETVAL

            

char*
certificate_file(LassoSamlpResponseAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->certificate_file, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->certificate_file;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibNameIdentifierMappingResponse	PREFIX = lasso_lib_name_identifier_mapping_response_


LassoNode*
lasso_lib_name_identifier_mapping_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_name_identifier_mapping_response_new_full( provideRID,statusCodeValue,request,sign_type,sign_method )
  string_non_null provideRID
  string_non_null statusCodeValue
  LassoLibNameIdentifierMappingRequest* request
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_name_identifier_mapping_response_new_full(provideRID ,statusCodeValue ,request ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibNameIdentifierMappingResponse* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibNameIdentifierMappingResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlpStatus*
Status(LassoLibNameIdentifierMappingResponse* obj, LassoSamlpStatus* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Status, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Status;
        }
    OUTPUT:
        RETVAL

            

LassoSamlNameIdentifier*
NameIdentifier(LassoLibNameIdentifierMappingResponse* obj, LassoSamlNameIdentifier* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIdentifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIdentifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SamlpResponse	PREFIX = lasso_samlp_response_


LassoNode*
lasso_samlp_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlpStatus*
Status(LassoSamlpResponse* obj, LassoSamlpStatus* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Status, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Status;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
Assertion(LassoSamlpResponse* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Assertion);
            for (; i < items; i++) {
                LassoSamlAssertion* data;
                data = (LassoSamlAssertion*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Assertion);
                    croak("an element cannot be converted to an LassoSamlAssertion*");
                }
                lasso_list_add_gobject(obj->Assertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Assertion;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibStatusResponse	PREFIX = lasso_lib_status_response_


LassoNode*
lasso_lib_status_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibStatusResponse* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibStatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlpStatus*
Status(LassoLibStatusResponse* obj, LassoSamlpStatus* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Status, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Status;
        }
    OUTPUT:
        RETVAL

            

char*
RelayState(LassoLibStatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RelayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RelayState;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::LibLogoutResponse	PREFIX = lasso_lib_logout_response_


LassoNode*
lasso_lib_logout_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_logout_response_new_full( providerID,statusCodeValue,request,sign_type,sign_method )
  string_non_null providerID
  string_non_null statusCodeValue
  LassoLibLogoutRequest* request
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_logout_response_new_full(providerID ,statusCodeValue ,request ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::LibRegisterNameIdentifierResponse	PREFIX = lasso_lib_register_name_identifier_response_


LassoNode*
lasso_lib_register_name_identifier_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_lib_register_name_identifier_response_new_full( providerID,statusCodeValue,request,sign_type,sign_method )
  string_non_null providerID
  string_non_null statusCodeValue
  LassoLibRegisterNameIdentifierRequest* request
  LassoSignatureType sign_type
  LassoSignatureMethod sign_method
   CODE:
       RETVAL = (LassoNode*)lasso_lib_register_name_identifier_response_new_full(providerID ,statusCodeValue ,request ,sign_type ,sign_method);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::LibAuthnResponse	PREFIX = lasso_lib_authn_response_


LassoNode*
lasso_lib_authn_response_new( cls,providerID,request )
  char *cls
  string_non_null providerID
  LassoLibAuthnRequest* request
  INIT:
    cls = NULL;
  C_ARGS:
    providerID, request
  CLEANUP:
    lasso_unref(RETVAL);

GList_xmlnode
Extension(LassoLibAuthnResponse* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->Extension);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->Extension);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->Extension, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Extension;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderID(LassoLibAuthnResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

char*
RelayState(LassoLibAuthnResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RelayState, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RelayState;
        }
    OUTPUT:
        RETVAL

            

char*
consent(LassoLibAuthnResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->consent;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2RequestAbstract	PREFIX = lasso_samlp2_request_abstract_


LassoNode*
lasso_samlp2_request_abstract_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2NameID*
Issuer(LassoSamlp2RequestAbstract* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Issuer, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Issuer;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2Extensions*
Extensions(LassoSamlp2RequestAbstract* obj, LassoSamlp2Extensions* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Extensions, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Extensions;
        }
    OUTPUT:
        RETVAL

            

char*
ID(LassoSamlp2RequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ID;
        }
    OUTPUT:
        RETVAL

            

char*
Version(LassoSamlp2RequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Version, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Version;
        }
    OUTPUT:
        RETVAL

            

char*
IssueInstant(LassoSamlp2RequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IssueInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IssueInstant;
        }
    OUTPUT:
        RETVAL

            

char*
Destination(LassoSamlp2RequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Destination, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Destination;
        }
    OUTPUT:
        RETVAL

            

char*
Consent(LassoSamlp2RequestAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Consent;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2AssertionIDRequest	PREFIX = lasso_samlp2_assertion_id_request_


LassoNode*
lasso_samlp2_assertion_id_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
AssertionIDRef(LassoSamlp2AssertionIDRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionIDRef, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionIDRef;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2SubjectConfirmationData	PREFIX = lasso_saml2_subject_confirmation_data_


LassoNode*
lasso_saml2_subject_confirmation_data_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
NotBefore(LassoSaml2SubjectConfirmationData* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotBefore, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotBefore;
        }
    OUTPUT:
        RETVAL

            

char*
NotOnOrAfter(LassoSaml2SubjectConfirmationData* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

char*
Recipient(LassoSaml2SubjectConfirmationData* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Recipient, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Recipient;
        }
    OUTPUT:
        RETVAL

            

char*
InResponseTo(LassoSaml2SubjectConfirmationData* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->InResponseTo, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->InResponseTo;
        }
    OUTPUT:
        RETVAL

            

char*
Address(LassoSaml2SubjectConfirmationData* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Address, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Address;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2SubjectLocality	PREFIX = lasso_saml2_subject_locality_


LassoNode*
lasso_saml2_subject_locality_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
Address(LassoSaml2SubjectLocality* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Address, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Address;
        }
    OUTPUT:
        RETVAL

            

char*
DNSName(LassoSaml2SubjectLocality* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->DNSName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->DNSName;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2ConditionAbstract	PREFIX = lasso_saml2_condition_abstract_


LassoNode*
lasso_saml2_condition_abstract_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Samlp2NameIDPolicy	PREFIX = lasso_samlp2_name_id_policy_


LassoNode*
lasso_samlp2_name_id_policy_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
Format(LassoSamlp2NameIDPolicy* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Format, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Format;
        }
    OUTPUT:
        RETVAL

            

char*
SPNameQualifier(LassoSamlp2NameIDPolicy* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SPNameQualifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SPNameQualifier;
        }
    OUTPUT:
        RETVAL

            

gboolean
AllowCreate(LassoSamlp2NameIDPolicy* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->AllowCreate, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AllowCreate;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2Subject	PREFIX = lasso_saml2_subject_


LassoNode*
lasso_saml2_subject_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2BaseIDAbstract*
BaseID(LassoSaml2Subject* obj, LassoSaml2BaseIDAbstract* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->BaseID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->BaseID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2NameID*
NameID(LassoSaml2Subject* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedID(LassoSaml2Subject* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2SubjectConfirmation*
SubjectConfirmation(LassoSaml2Subject* obj, LassoSaml2SubjectConfirmation* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SubjectConfirmation, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectConfirmation;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2Scoping	PREFIX = lasso_samlp2_scoping_


LassoNode*
lasso_samlp2_scoping_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlp2IDPList*
IDPList(LassoSamlp2Scoping* obj, LassoSamlp2IDPList* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPList, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPList;
        }
    OUTPUT:
        RETVAL

            

char*
RequesterID(LassoSamlp2Scoping* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->RequesterID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RequesterID;
        }
    OUTPUT:
        RETVAL

            

char*
ProxyCount(LassoSamlp2Scoping* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProxyCount, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProxyCount;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2LogoutRequest	PREFIX = lasso_samlp2_logout_request_


LassoNode*
lasso_samlp2_logout_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_string
lasso_samlp2_logout_request_get_session_indexes( logout_request )
  LassoSamlp2LogoutRequest* logout_request
  INIT:
    check_gobject((GObject*)logout_request, lasso_samlp2_logout_request_get_type());

void
lasso_samlp2_logout_request_set_session_indexes( logout_request,session_index )
  LassoSamlp2LogoutRequest* logout_request
  GList_string session_index
  INIT:
    check_gobject((GObject*)logout_request, lasso_samlp2_logout_request_get_type());
PROTOTYPE:  $\@
  CLEANUP:
    lasso_release_list_of_strings(session_index);

LassoSaml2BaseIDAbstract*
BaseID(LassoSamlp2LogoutRequest* obj, LassoSaml2BaseIDAbstract* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->BaseID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->BaseID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2NameID*
NameID(LassoSamlp2LogoutRequest* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedID(LassoSamlp2LogoutRequest* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedID;
        }
    OUTPUT:
        RETVAL

            

char*
SessionIndex(LassoSamlp2LogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SessionIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SessionIndex;
        }
    OUTPUT:
        RETVAL

            

char*
Reason(LassoSamlp2LogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Reason, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Reason;
        }
    OUTPUT:
        RETVAL

            

char*
NotOnOrAfter(LassoSamlp2LogoutRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2BaseIDAbstract	PREFIX = lasso_saml2_base_id_abstract_


char*
NameQualifier(LassoSaml2BaseIDAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NameQualifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameQualifier;
        }
    OUTPUT:
        RETVAL

            

char*
SPNameQualifier(LassoSaml2BaseIDAbstract* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SPNameQualifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SPNameQualifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2IDPEntry	PREFIX = lasso_samlp2_idp_entry_


LassoNode*
lasso_samlp2_idp_entry_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
ProviderID(LassoSamlp2IDPEntry* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderID;
        }
    OUTPUT:
        RETVAL

            

char*
Name(LassoSamlp2IDPEntry* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Name, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Name;
        }
    OUTPUT:
        RETVAL

            

char*
Loc(LassoSamlp2IDPEntry* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Loc, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Loc;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2AudienceRestriction	PREFIX = lasso_saml2_audience_restriction_


LassoNode*
lasso_saml2_audience_restriction_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
Audience(LassoSaml2AudienceRestriction* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Audience, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Audience;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2AuthnContext	PREFIX = lasso_saml2_authn_context_


LassoNode*
lasso_saml2_authn_context_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
AuthnContextClassRef(LassoSaml2AuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthnContextClassRef, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextClassRef;
        }
    OUTPUT:
        RETVAL

            

char*
AuthnContextDeclRef(LassoSaml2AuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthnContextDeclRef, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextDeclRef;
        }
    OUTPUT:
        RETVAL

            

char*
AuthenticatingAuthority(LassoSaml2AuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthenticatingAuthority, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthenticatingAuthority;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2IDPList	PREFIX = lasso_samlp2_idp_list_


LassoNode*
lasso_samlp2_idp_list_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlp2IDPEntry*
IDPEntry(LassoSamlp2IDPList* obj, LassoSamlp2IDPEntry* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->IDPEntry, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IDPEntry;
        }
    OUTPUT:
        RETVAL

            

char*
GetComplete(LassoSamlp2IDPList* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->GetComplete, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->GetComplete;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2ProxyRestriction	PREFIX = lasso_saml2_proxy_restriction_


LassoNode*
lasso_saml2_proxy_restriction_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
Audience(LassoSaml2ProxyRestriction* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Audience, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Audience;
        }
    OUTPUT:
        RETVAL

            

char*
Count(LassoSaml2ProxyRestriction* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Count, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Count;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2SubjectQueryAbstract	PREFIX = lasso_samlp2_subject_query_abstract_


LassoNode*
lasso_samlp2_subject_query_abstract_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2Subject*
Subject(LassoSamlp2SubjectQueryAbstract* obj, LassoSaml2Subject* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Subject, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Subject;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2AttributeQuery	PREFIX = lasso_samlp2_attribute_query_


LassoNode*
lasso_samlp2_attribute_query_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Attribute(LassoSamlp2AttributeQuery* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Attribute);
            for (; i < items; i++) {
                LassoSaml2Attribute* data;
                data = (LassoSaml2Attribute*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Attribute);
                    croak("an element cannot be converted to an LassoSaml2Attribute*");
                }
                lasso_list_add_gobject(obj->Attribute, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Attribute;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2ManageNameIDRequest	PREFIX = lasso_samlp2_manage_name_id_request_


LassoNode*
lasso_samlp2_manage_name_id_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2NameID*
NameID(LassoSamlp2ManageNameIDRequest* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedID(LassoSamlp2ManageNameIDRequest* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedID;
        }
    OUTPUT:
        RETVAL

            

char*
NewID(LassoSamlp2ManageNameIDRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NewID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NewID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
NewEncryptedID(LassoSamlp2ManageNameIDRequest* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NewEncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NewEncryptedID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2Terminate*
Terminate(LassoSamlp2ManageNameIDRequest* obj, LassoSamlp2Terminate* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Terminate, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Terminate;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2Extensions	PREFIX = lasso_samlp2_extensions_


LassoNode*
lasso_samlp2_extensions_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Samlp2StatusResponse	PREFIX = lasso_samlp2_status_response_


LassoNode*
lasso_samlp2_status_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2NameID*
Issuer(LassoSamlp2StatusResponse* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Issuer, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Issuer;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2Extensions*
Extensions(LassoSamlp2StatusResponse* obj, LassoSamlp2Extensions* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Extensions, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Extensions;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2Status*
Status(LassoSamlp2StatusResponse* obj, LassoSamlp2Status* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Status, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Status;
        }
    OUTPUT:
        RETVAL

            

char*
ID(LassoSamlp2StatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ID;
        }
    OUTPUT:
        RETVAL

            

char*
InResponseTo(LassoSamlp2StatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->InResponseTo, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->InResponseTo;
        }
    OUTPUT:
        RETVAL

            

char*
Version(LassoSamlp2StatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Version, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Version;
        }
    OUTPUT:
        RETVAL

            

char*
IssueInstant(LassoSamlp2StatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IssueInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IssueInstant;
        }
    OUTPUT:
        RETVAL

            

char*
Destination(LassoSamlp2StatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Destination, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Destination;
        }
    OUTPUT:
        RETVAL

            

char*
Consent(LassoSamlp2StatusResponse* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Consent, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Consent;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2ManageNameIDResponse	PREFIX = lasso_samlp2_manage_name_id_response_


LassoNode*
lasso_samlp2_manage_name_id_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Samlp2ArtifactResponse	PREFIX = lasso_samlp2_artifact_response_


LassoNode*
lasso_samlp2_artifact_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
any(LassoSamlp2ArtifactResponse* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->any, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->any;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2Attribute	PREFIX = lasso_saml2_attribute_


LassoNode*
lasso_saml2_attribute_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
AttributeValue(LassoSaml2Attribute* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AttributeValue);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AttributeValue);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AttributeValue, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeValue;
        }
    OUTPUT:
        RETVAL

            

char*
Name(LassoSaml2Attribute* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Name, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Name;
        }
    OUTPUT:
        RETVAL

            

char*
NameFormat(LassoSaml2Attribute* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NameFormat, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameFormat;
        }
    OUTPUT:
        RETVAL

            

char*
FriendlyName(LassoSaml2Attribute* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->FriendlyName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->FriendlyName;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2Status	PREFIX = lasso_samlp2_status_


LassoNode*
lasso_samlp2_status_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlp2StatusCode*
StatusCode(LassoSamlp2Status* obj, LassoSamlp2StatusCode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->StatusCode, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusCode;
        }
    OUTPUT:
        RETVAL

            

char*
StatusMessage(LassoSamlp2Status* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->StatusMessage, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusMessage;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2StatusDetail*
StatusDetail(LassoSamlp2Status* obj, LassoSamlp2StatusDetail* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->StatusDetail, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusDetail;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2SubjectConfirmation	PREFIX = lasso_saml2_subject_confirmation_


LassoNode*
lasso_saml2_subject_confirmation_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2BaseIDAbstract*
BaseID(LassoSaml2SubjectConfirmation* obj, LassoSaml2BaseIDAbstract* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->BaseID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->BaseID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2NameID*
NameID(LassoSaml2SubjectConfirmation* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedID(LassoSaml2SubjectConfirmation* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2SubjectConfirmationData*
SubjectConfirmationData(LassoSaml2SubjectConfirmation* obj, LassoSaml2SubjectConfirmationData* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SubjectConfirmationData, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectConfirmationData;
        }
    OUTPUT:
        RETVAL

            

char*
Method(LassoSaml2SubjectConfirmation* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Method, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Method;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2Terminate	PREFIX = lasso_samlp2_terminate_


LassoNode*
lasso_samlp2_terminate_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Saml2Evidence	PREFIX = lasso_saml2_evidence_


LassoNode*
lasso_saml2_evidence_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
AssertionIDRef(LassoSaml2Evidence* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AssertionIDRef);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AssertionIDRef);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AssertionIDRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionIDRef;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AssertionURIRef(LassoSaml2Evidence* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AssertionURIRef);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AssertionURIRef);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AssertionURIRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionURIRef;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
Assertion(LassoSaml2Evidence* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Assertion);
            for (; i < items; i++) {
                LassoSaml2Assertion* data;
                data = (LassoSaml2Assertion*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Assertion);
                    croak("an element cannot be converted to an LassoSaml2Assertion*");
                }
                lasso_list_add_gobject(obj->Assertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Assertion;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
EncryptedAssertion(LassoSaml2Evidence* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->EncryptedAssertion);
            for (; i < items; i++) {
                LassoSaml2EncryptedElement* data;
                data = (LassoSaml2EncryptedElement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->EncryptedAssertion);
                    croak("an element cannot be converted to an LassoSaml2EncryptedElement*");
                }
                lasso_list_add_gobject(obj->EncryptedAssertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedAssertion;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2Advice	PREFIX = lasso_saml2_advice_


LassoNode*
lasso_saml2_advice_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
AssertionIDRef(LassoSaml2Advice* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AssertionIDRef);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AssertionIDRef);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AssertionIDRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionIDRef;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AssertionURIRef(LassoSaml2Advice* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AssertionURIRef);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AssertionURIRef);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->AssertionURIRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionURIRef;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
Assertion(LassoSaml2Advice* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Assertion);
            for (; i < items; i++) {
                LassoSaml2Assertion* data;
                data = (LassoSaml2Assertion*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Assertion);
                    croak("an element cannot be converted to an LassoSaml2Assertion*");
                }
                lasso_list_add_gobject(obj->Assertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Assertion;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
EncryptedAssertion(LassoSaml2Advice* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->EncryptedAssertion);
            for (; i < items; i++) {
                LassoSaml2EncryptedElement* data;
                data = (LassoSaml2EncryptedElement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->EncryptedAssertion);
                    croak("an element cannot be converted to an LassoSaml2EncryptedElement*");
                }
                lasso_list_add_gobject(obj->EncryptedAssertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedAssertion;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2Response	PREFIX = lasso_samlp2_response_


LassoNode*
lasso_samlp2_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Assertion(LassoSamlp2Response* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Assertion);
            for (; i < items; i++) {
                LassoSaml2Assertion* data;
                data = (LassoSaml2Assertion*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Assertion);
                    croak("an element cannot be converted to an LassoSaml2Assertion*");
                }
                lasso_list_add_gobject(obj->Assertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Assertion;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
EncryptedAssertion(LassoSamlp2Response* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->EncryptedAssertion);
            for (; i < items; i++) {
                LassoSaml2EncryptedElement* data;
                data = (LassoSaml2EncryptedElement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->EncryptedAssertion);
                    croak("an element cannot be converted to an LassoSaml2EncryptedElement*");
                }
                lasso_list_add_gobject(obj->EncryptedAssertion, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedAssertion;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2AuthnRequest	PREFIX = lasso_samlp2_authn_request_


LassoNode*
lasso_samlp2_authn_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2Subject*
Subject(LassoSamlp2AuthnRequest* obj, LassoSaml2Subject* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Subject, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Subject;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2NameIDPolicy*
NameIDPolicy(LassoSamlp2AuthnRequest* obj, LassoSamlp2NameIDPolicy* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIDPolicy, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIDPolicy;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2Conditions*
Conditions(LassoSamlp2AuthnRequest* obj, LassoSaml2Conditions* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Conditions, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Conditions;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2RequestedAuthnContext*
RequestedAuthnContext(LassoSamlp2AuthnRequest* obj, LassoSamlp2RequestedAuthnContext* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->RequestedAuthnContext, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RequestedAuthnContext;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2Scoping*
Scoping(LassoSamlp2AuthnRequest* obj, LassoSamlp2Scoping* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Scoping, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Scoping;
        }
    OUTPUT:
        RETVAL

            

gboolean
ForceAuthn(LassoSamlp2AuthnRequest* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->ForceAuthn, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ForceAuthn;
        }
    OUTPUT:
        RETVAL

            

gboolean
IsPassive(LassoSamlp2AuthnRequest* obj, gboolean value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->IsPassive, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IsPassive;
        }
    OUTPUT:
        RETVAL

            

char*
ProtocolBinding(LassoSamlp2AuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProtocolBinding, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProtocolBinding;
        }
    OUTPUT:
        RETVAL

            

int
AssertionConsumerServiceIndex(LassoSamlp2AuthnRequest* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->AssertionConsumerServiceIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionConsumerServiceIndex;
        }
    OUTPUT:
        RETVAL

            

char*
AssertionConsumerServiceURL(LassoSamlp2AuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AssertionConsumerServiceURL, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AssertionConsumerServiceURL;
        }
    OUTPUT:
        RETVAL

            

int
AttributeConsumingServiceIndex(LassoSamlp2AuthnRequest* obj, int value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_simple(obj->AttributeConsumingServiceIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeConsumingServiceIndex;
        }
    OUTPUT:
        RETVAL

            

char*
ProviderName(LassoSamlp2AuthnRequest* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ProviderName, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ProviderName;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2Assertion	PREFIX = lasso_saml2_assertion_


LassoNode*
lasso_saml2_assertion_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

gboolean
lasso_saml2_assertion_has_audience_restriction( saml2_assertion )
  LassoSaml2Assertion* saml2_assertion
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

gboolean
lasso_saml2_assertion_is_audience_restricted( saml2_assertion,providerID )
  LassoSaml2Assertion* saml2_assertion
  string_non_null providerID
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_set_subject_name_id( saml2_assertion,node )
  LassoSaml2Assertion* saml2_assertion
  LassoNode* node
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_set_subject_confirmation_name_id( saml2_assertion,node )
  LassoSaml2Assertion* saml2_assertion
  LassoNode* node
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_set_subject_confirmation_data( saml2_assertion,tolerance,length,Recipient,InResponseTo,Address )
  LassoSaml2Assertion* saml2_assertion
  time_t tolerance
  time_t length
  string_non_null Recipient
  string_non_null InResponseTo
  string_non_null Address
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_set_basic_conditions( saml2_assertion,tolerance = -1,length = -1,one_time_use = FALSE )
  LassoSaml2Assertion* saml2_assertion
  time_t tolerance
  time_t length
  gboolean one_time_use
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_add_audience_restriction( saml2_assertion,providerID )
  LassoSaml2Assertion* saml2_assertion
  string_non_null providerID
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_add_proxy_limit( saml2_assertion,proxy_count = -1,proxy_audiences = NULL )
  LassoSaml2Assertion* saml2_assertion
  int proxy_count
  GList_string proxy_audiences
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());
PROTOTYPE:  $;$\@
  CLEANUP:
    lasso_release_list_of_strings(proxy_audiences);

LassoSaml2AssertionValidationState
lasso_saml2_assertion_validate_conditions( saml2_assertion,relaying_party_providerID = NULL )
  LassoSaml2Assertion* saml2_assertion
  string_or_null relaying_party_providerID
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

LassoProvider*
lasso_saml2_assertion_get_issuer_provider( saml2_assertion,server )
  LassoSaml2Assertion* saml2_assertion
  LassoServer* server
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_saml2_assertion_add_attribute_with_node( assertion,name,nameformat,content )
  LassoSaml2Assertion* assertion
  string_non_null name
  string_non_null nameformat
  LassoNode* content
  INIT:
    check_gobject((GObject*)assertion, lasso_saml2_assertion_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoSaml2SubjectConfirmationData*
lasso_saml2_assertion_get_subject_confirmation_data( saml2_assertion,create )
  LassoSaml2Assertion* saml2_assertion
  gboolean create
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());
  CLEANUP:
    lasso_unref(RETVAL);

const char*
lasso_saml2_assertion_get_in_response_to( assertion )
  LassoSaml2Assertion* assertion
  INIT:
    check_gobject((GObject*)assertion, lasso_saml2_assertion_get_type());

lasso_error_t
lasso_saml2_assertion_decrypt_subject( assertion,server )
  LassoSaml2Assertion* assertion
  LassoServer* server
  INIT:
    check_gobject((GObject*)assertion, lasso_saml2_assertion_get_type());
  CLEANUP:
    gperl_lasso_error(RETVAL);

LassoSaml2AssertionValidationState
lasso_saml2_assertion_validate_time_checks( saml2_assertion,tolerance,now = 0 )
  LassoSaml2Assertion* saml2_assertion
  unsigned int tolerance
  time_t now
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

LassoSaml2AssertionValidationState
lasso_saml2_assertion_validate_audience( saml2_assertion,audience )
  LassoSaml2Assertion* saml2_assertion
  string_non_null audience
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

gboolean
lasso_saml2_assertion_has_one_time_use( saml2_assertion )
  LassoSaml2Assertion* saml2_assertion
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

LassoSaml2AssertionValidationState
lasso_saml2_assertion_allows_proxying( saml2_assertion )
  LassoSaml2Assertion* saml2_assertion
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

LassoSaml2AssertionValidationState
lasso_saml2_assertion_allows_proxying_to( saml2_assertion,audience = NULL )
  LassoSaml2Assertion* saml2_assertion
  string_or_null audience
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

void
lasso_saml2_assertion_set_one_time_use( saml2_assertion,one_time_use )
  LassoSaml2Assertion* saml2_assertion
  gboolean one_time_use
  INIT:
    check_gobject((GObject*)saml2_assertion, lasso_saml2_assertion_get_type());

LassoSaml2NameID*
Issuer(LassoSaml2Assertion* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Issuer, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Issuer;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2Subject*
Subject(LassoSaml2Assertion* obj, LassoSaml2Subject* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Subject, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Subject;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2Conditions*
Conditions(LassoSaml2Assertion* obj, LassoSaml2Conditions* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Conditions, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Conditions;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2Advice*
Advice(LassoSaml2Assertion* obj, LassoSaml2Advice* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Advice, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Advice;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
Statement(LassoSaml2Assertion* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Statement);
            for (; i < items; i++) {
                LassoSaml2StatementAbstract* data;
                data = (LassoSaml2StatementAbstract*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Statement);
                    croak("an element cannot be converted to an LassoSaml2StatementAbstract*");
                }
                lasso_list_add_gobject(obj->Statement, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Statement;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AuthnStatement(LassoSaml2Assertion* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AuthnStatement);
            for (; i < items; i++) {
                LassoSaml2AuthnStatement* data;
                data = (LassoSaml2AuthnStatement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AuthnStatement);
                    croak("an element cannot be converted to an LassoSaml2AuthnStatement*");
                }
                lasso_list_add_gobject(obj->AuthnStatement, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnStatement;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AuthzDecisionStatement(LassoSaml2Assertion* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AuthzDecisionStatement);
            for (; i < items; i++) {
                LassoSaml2AuthzDecisionStatement* data;
                data = (LassoSaml2AuthzDecisionStatement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AuthzDecisionStatement);
                    croak("an element cannot be converted to an LassoSaml2AuthzDecisionStatement*");
                }
                lasso_list_add_gobject(obj->AuthzDecisionStatement, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthzDecisionStatement;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AttributeStatement(LassoSaml2Assertion* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AttributeStatement);
            for (; i < items; i++) {
                LassoSaml2AttributeStatement* data;
                data = (LassoSaml2AttributeStatement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AttributeStatement);
                    croak("an element cannot be converted to an LassoSaml2AttributeStatement*");
                }
                lasso_list_add_gobject(obj->AttributeStatement, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AttributeStatement;
        }
    OUTPUT:
        RETVAL

            

char*
Version(LassoSaml2Assertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Version, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Version;
        }
    OUTPUT:
        RETVAL

            

char*
ID(LassoSaml2Assertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->ID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->ID;
        }
    OUTPUT:
        RETVAL

            

char*
IssueInstant(LassoSaml2Assertion* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->IssueInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->IssueInstant;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2NameIDMappingRequest	PREFIX = lasso_samlp2_name_id_mapping_request_


LassoNode*
lasso_samlp2_name_id_mapping_request_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2BaseIDAbstract*
BaseID(LassoSamlp2NameIDMappingRequest* obj, LassoSaml2BaseIDAbstract* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->BaseID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->BaseID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2NameID*
NameID(LassoSamlp2NameIDMappingRequest* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedID(LassoSamlp2NameIDMappingRequest* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedID;
        }
    OUTPUT:
        RETVAL

            

LassoSamlp2NameIDPolicy*
NameIDPolicy(LassoSamlp2NameIDMappingRequest* obj, LassoSamlp2NameIDPolicy* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameIDPolicy, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameIDPolicy;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2AuthnQuery	PREFIX = lasso_samlp2_authn_query_


LassoNode*
lasso_samlp2_authn_query_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlp2RequestedAuthnContext*
RequestedAuthnContext(LassoSamlp2AuthnQuery* obj, LassoSamlp2RequestedAuthnContext* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->RequestedAuthnContext, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->RequestedAuthnContext;
        }
    OUTPUT:
        RETVAL

            

char*
SessionIndex(LassoSamlp2AuthnQuery* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SessionIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SessionIndex;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2LogoutResponse	PREFIX = lasso_samlp2_logout_response_


LassoNode*
lasso_samlp2_logout_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Samlp2StatusCode	PREFIX = lasso_samlp2_status_code_


LassoNode*
lasso_samlp2_status_code_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSamlp2StatusCode*
StatusCode(LassoSamlp2StatusCode* obj, LassoSamlp2StatusCode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->StatusCode, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->StatusCode;
        }
    OUTPUT:
        RETVAL

            

char*
Value(LassoSamlp2StatusCode* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Value, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Value;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2EncryptedElement	PREFIX = lasso_saml2_encrypted_element_


LassoNode*
lasso_saml2_encrypted_element_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

lasso_error_t
lasso_saml2_encrypted_element_server_decrypt( encrypted_element,server,decrypted_node )
  LassoSaml2EncryptedElement* encrypted_element
  LassoServer* server
  LassoNode* &decrypted_node = NO_INIT
  INIT:
    check_gobject((GObject*)encrypted_element, lasso_saml2_encrypted_element_get_type());
  INIT:
    decrypted_node = NULL;
  OUTPUT:
    decrypted_node
  CLEANUP:
    gperl_lasso_error(RETVAL);

xmlNode*
EncryptedData(LassoSaml2EncryptedElement* obj, xmlNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_xml_node(obj->EncryptedData, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedData;
        }
    OUTPUT:
        RETVAL

            

GList_xmlnode
EncryptedKey(LassoSaml2EncryptedElement* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_xml_node(obj->EncryptedKey);
            for (; i < items; i++) {
                xmlNode* data;
                data = (xmlNode*)pv_to_xmlnode(ST(i));
                if (! data) {
                    lasso_release_list_of_xml_node(obj->EncryptedKey);
                    croak("an element cannot be converted to an xmlNode*");
                }
                lasso_list_add_new_xml_node(obj->EncryptedKey, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedKey;
        }
    OUTPUT:
        RETVAL

            

LassoNode*
original_data(LassoSaml2EncryptedElement* obj, LassoNode* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->original_data, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->original_data;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2AuthzDecisionQuery	PREFIX = lasso_samlp2_authz_decision_query_


LassoNode*
lasso_samlp2_authz_decision_query_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2Action*
Action(LassoSamlp2AuthzDecisionQuery* obj, LassoSaml2Action* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Action, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Action;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2Evidence*
Evidence(LassoSamlp2AuthzDecisionQuery* obj, LassoSaml2Evidence* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Evidence, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Evidence;
        }
    OUTPUT:
        RETVAL

            

char*
Resource(LassoSamlp2AuthzDecisionQuery* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Resource, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Resource;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2StatementAbstract	PREFIX = lasso_saml2_statement_abstract_


LassoNode*
lasso_saml2_statement_abstract_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Saml2AttributeStatement	PREFIX = lasso_saml2_attribute_statement_


LassoNode*
lasso_saml2_attribute_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Attribute(LassoSaml2AttributeStatement* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Attribute);
            for (; i < items; i++) {
                LassoSaml2Attribute* data;
                data = (LassoSaml2Attribute*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Attribute);
                    croak("an element cannot be converted to an LassoSaml2Attribute*");
                }
                lasso_list_add_gobject(obj->Attribute, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Attribute;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
EncryptedAttribute(LassoSaml2AttributeStatement* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->EncryptedAttribute);
            for (; i < items; i++) {
                LassoSaml2EncryptedElement* data;
                data = (LassoSaml2EncryptedElement*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->EncryptedAttribute);
                    croak("an element cannot be converted to an LassoSaml2EncryptedElement*");
                }
                lasso_list_add_gobject(obj->EncryptedAttribute, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedAttribute;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2AuthnStatement	PREFIX = lasso_saml2_authn_statement_


LassoNode*
lasso_saml2_authn_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2SubjectLocality*
SubjectLocality(LassoSaml2AuthnStatement* obj, LassoSaml2SubjectLocality* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->SubjectLocality, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SubjectLocality;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2AuthnContext*
AuthnContext(LassoSaml2AuthnStatement* obj, LassoSaml2AuthnContext* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->AuthnContext, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContext;
        }
    OUTPUT:
        RETVAL

            

char*
AuthnInstant(LassoSaml2AuthnStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->AuthnInstant, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnInstant;
        }
    OUTPUT:
        RETVAL

            

char*
SessionIndex(LassoSaml2AuthnStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SessionIndex, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SessionIndex;
        }
    OUTPUT:
        RETVAL

            

char*
SessionNotOnOrAfter(LassoSaml2AuthnStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SessionNotOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SessionNotOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2AuthzDecisionStatement	PREFIX = lasso_saml2_authz_decision_statement_


LassoNode*
lasso_saml2_authz_decision_statement_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2Action*
Action(LassoSaml2AuthzDecisionStatement* obj, LassoSaml2Action* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Action, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Action;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2Evidence*
Evidence(LassoSaml2AuthzDecisionStatement* obj, LassoSaml2Evidence* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Evidence, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Evidence;
        }
    OUTPUT:
        RETVAL

            

char*
Resource(LassoSaml2AuthzDecisionStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Resource, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Resource;
        }
    OUTPUT:
        RETVAL

            

char*
Decision(LassoSaml2AuthzDecisionStatement* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Decision, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Decision;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2AttributeValue	PREFIX = lasso_saml2_attribute_value_


LassoSaml2AttributeValue*
lasso_saml2_attribute_value_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
any(LassoSaml2AttributeValue* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->any);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->any);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->any, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->any;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2Action	PREFIX = lasso_saml2_action_


LassoNode*
lasso_saml2_action_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_saml2_action_new_with_string( content )
  string_non_null content
   CODE:
       RETVAL = (LassoNode*)lasso_saml2_action_new_with_string(content);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

char*
content(LassoSaml2Action* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->content, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->content;
        }
    OUTPUT:
        RETVAL

            

char*
Namespace(LassoSaml2Action* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Namespace, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Namespace;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2OneTimeUse	PREFIX = lasso_saml2_one_time_use_


LassoNode*
lasso_saml2_one_time_use_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Saml2NameID	PREFIX = lasso_saml2_name_id_


LassoSaml2NameID*
lasso_saml2_name_id_new_with_persistent_format( id,idpID,providerID )
  string_non_null id
  string_non_null idpID
  string_non_null providerID
   CODE:
       RETVAL = (LassoSaml2NameID*)lasso_saml2_name_id_new_with_persistent_format(id ,idpID ,providerID);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_saml2_name_id_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoNode*
lasso_saml2_name_id_new_with_string( content )
  string_non_null content
   CODE:
       RETVAL = (LassoNode*)lasso_saml2_name_id_new_with_string(content);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

gboolean
lasso_saml2_name_id_equals( name_id,other_name_id )
  LassoSaml2NameID* name_id
  LassoSaml2NameID* other_name_id
  INIT:
    check_gobject((GObject*)name_id, lasso_saml2_name_id_get_type());

char*
content(LassoSaml2NameID* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->content, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->content;
        }
    OUTPUT:
        RETVAL

            

char*
Format(LassoSaml2NameID* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Format, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Format;
        }
    OUTPUT:
        RETVAL

            

char*
SPProvidedID(LassoSaml2NameID* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SPProvidedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SPProvidedID;
        }
    OUTPUT:
        RETVAL

            

char*
NameQualifier(LassoSaml2NameID* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NameQualifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameQualifier;
        }
    OUTPUT:
        RETVAL

            

char*
SPNameQualifier(LassoSaml2NameID* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->SPNameQualifier, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->SPNameQualifier;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2KeyInfoConfirmationData	PREFIX = lasso_saml2_key_info_confirmation_data_


LassoNode*
lasso_saml2_key_info_confirmation_data_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Samlp2StatusDetail	PREFIX = lasso_samlp2_status_detail_


LassoNode*
lasso_samlp2_status_detail_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

MODULE = Lasso	PACKAGE = Lasso::Samlp2ArtifactResolve	PREFIX = lasso_samlp2_artifact_resolve_


LassoNode*
lasso_samlp2_artifact_resolve_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

char*
Artifact(LassoSamlp2ArtifactResolve* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Artifact, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Artifact;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2NameIDMappingResponse	PREFIX = lasso_samlp2_name_id_mapping_response_


LassoNode*
lasso_samlp2_name_id_mapping_response_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSaml2NameID*
NameID(LassoSamlp2NameIDMappingResponse* obj, LassoSaml2NameID* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->NameID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NameID;
        }
    OUTPUT:
        RETVAL

            

LassoSaml2EncryptedElement*
EncryptedID(LassoSamlp2NameIDMappingResponse* obj, LassoSaml2EncryptedElement* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->EncryptedID, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->EncryptedID;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Samlp2RequestedAuthnContext	PREFIX = lasso_samlp2_requested_authn_context_


LassoNode*
lasso_samlp2_requested_authn_context_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_string
AuthnContextClassRef(LassoSamlp2RequestedAuthnContext* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->AuthnContextClassRef);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->AuthnContextClassRef);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->AuthnContextClassRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextClassRef;
        }
    OUTPUT:
        RETVAL

            

GList_string
AuthnContextDeclRef(LassoSamlp2RequestedAuthnContext* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->AuthnContextDeclRef);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->AuthnContextDeclRef);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->AuthnContextDeclRef, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AuthnContextDeclRef;
        }
    OUTPUT:
        RETVAL

            

char*
Comparison(LassoSamlp2RequestedAuthnContext* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Comparison, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Comparison;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::Saml2Conditions	PREFIX = lasso_saml2_conditions_


LassoNode*
lasso_saml2_conditions_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Condition(LassoSaml2Conditions* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Condition);
            for (; i < items; i++) {
                LassoSaml2ConditionAbstract* data;
                data = (LassoSaml2ConditionAbstract*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Condition);
                    croak("an element cannot be converted to an LassoSaml2ConditionAbstract*");
                }
                lasso_list_add_gobject(obj->Condition, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Condition;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
AudienceRestriction(LassoSaml2Conditions* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->AudienceRestriction);
            for (; i < items; i++) {
                LassoSaml2AudienceRestriction* data;
                data = (LassoSaml2AudienceRestriction*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->AudienceRestriction);
                    croak("an element cannot be converted to an LassoSaml2AudienceRestriction*");
                }
                lasso_list_add_gobject(obj->AudienceRestriction, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->AudienceRestriction;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
OneTimeUse(LassoSaml2Conditions* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->OneTimeUse);
            for (; i < items; i++) {
                LassoSaml2OneTimeUse* data;
                data = (LassoSaml2OneTimeUse*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->OneTimeUse);
                    croak("an element cannot be converted to an LassoSaml2OneTimeUse*");
                }
                lasso_list_add_gobject(obj->OneTimeUse, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->OneTimeUse;
        }
    OUTPUT:
        RETVAL

            

GList_gobject
ProxyRestriction(LassoSaml2Conditions* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->ProxyRestriction);
            for (; i < items; i++) {
                LassoSaml2ProxyRestriction* data;
                data = (LassoSaml2ProxyRestriction*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->ProxyRestriction);
                    croak("an element cannot be converted to an LassoSaml2ProxyRestriction*");
                }
                lasso_list_add_gobject(obj->ProxyRestriction, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->ProxyRestriction;
        }
    OUTPUT:
        RETVAL

            

char*
NotBefore(LassoSaml2Conditions* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotBefore, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotBefore;
        }
    OUTPUT:
        RETVAL

            

char*
NotOnOrAfter(LassoSaml2Conditions* obj, char* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->NotOnOrAfter, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->NotOnOrAfter;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SoapEnvelope	PREFIX = lasso_soap_envelope_


LassoSoapEnvelope*
lasso_soap_envelope_new( cls,body )
  char *cls
  LassoSoapBody* body
  INIT:
    cls = NULL;
  C_ARGS:
    body
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapEnvelope*
lasso_soap_envelope_new_from_message( message )
  string_non_null message
   CODE:
       RETVAL = (LassoSoapEnvelope*)lasso_soap_envelope_new_from_message(message);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapHeader*
Header(LassoSoapEnvelope* obj, LassoSoapHeader* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Header, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Header;
        }
    OUTPUT:
        RETVAL

            

LassoSoapBody*
Body(LassoSoapEnvelope* obj, LassoSoapBody* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Body, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Body;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SoapBody	PREFIX = lasso_soap_body_


LassoSoapBody*
lasso_soap_body_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapBody*
lasso_soap_body_new_from_message( message )
  string_non_null message
   CODE:
       RETVAL = (LassoSoapBody*)lasso_soap_body_new_from_message(message);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
any(LassoSoapBody* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->any);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->any);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->any, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->any;
        }
    OUTPUT:
        RETVAL

            

gchar*
Id(LassoSoapBody* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->Id, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Id;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SoapHeader	PREFIX = lasso_soap_header_


LassoSoapHeader*
lasso_soap_header_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapHeader*
lasso_soap_header_new_from_message( message )
  string_non_null message
   CODE:
       RETVAL = (LassoSoapHeader*)lasso_soap_header_new_from_message(message);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
Other(LassoSoapHeader* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->Other);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->Other);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->Other, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->Other;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SoapFault	PREFIX = lasso_soap_fault_


LassoSoapFault*
lasso_soap_fault_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapFault*
lasso_soap_fault_new_from_message( message )
  string_non_null message
   CODE:
       RETVAL = (LassoSoapFault*)lasso_soap_fault_new_from_message(message);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapFault*
lasso_soap_fault_new_full( faultcode,faultstring )
  string_non_null faultcode
  string_non_null faultstring
   CODE:
       RETVAL = (LassoSoapFault*)lasso_soap_fault_new_full(faultcode ,faultstring);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

gchar*
faultcode(LassoSoapFault* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->faultcode, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->faultcode;
        }
    OUTPUT:
        RETVAL

            

gchar*
faultstring(LassoSoapFault* obj, gchar* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_string(obj->faultstring, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->faultstring;
        }
    OUTPUT:
        RETVAL

            

GList_string
faultactor(LassoSoapFault* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_strings(obj->faultactor);
            for (; i < items; i++) {
                char* data;
                data = (char*)SvPV_nolen(ST(i));
                if (! data) {
                    lasso_release_list_of_strings(obj->faultactor);
                    croak("an element cannot be converted to an char*");
                }
                lasso_list_add_string(obj->faultactor, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->faultactor;
        }
    OUTPUT:
        RETVAL

            

LassoSoapDetail*
Detail(LassoSoapFault* obj, LassoSoapDetail* value = 0)
    CODE:
        if (items > 1) {
            lasso_assign_gobject(obj->Detail, value);
            XSRETURN(0);
        } else {
            RETVAL = obj->Detail;
        }
    OUTPUT:
        RETVAL

            

MODULE = Lasso	PACKAGE = Lasso::SoapDetail	PREFIX = lasso_soap_detail_


LassoSoapDetail*
lasso_soap_detail_new( cls )
  char *cls
  INIT:
    cls = NULL;
  C_ARGS:
    
  CLEANUP:
    lasso_unref(RETVAL);

LassoSoapDetail*
lasso_soap_detail_new_from_message( message )
  string_non_null message
   CODE:
       RETVAL = (LassoSoapDetail*)lasso_soap_detail_new_from_message(message);
   OUTPUT:
         RETVAL
  CLEANUP:
    lasso_unref(RETVAL);

GList_gobject
any(LassoSoapDetail* obj, ...)
    PREINIT:
        int i = 1;
    CODE:
        if (items > 1) {
            lasso_release_list_of_gobjects(obj->any);
            for (; i < items; i++) {
                LassoNode* data;
                data = (LassoNode*)gperl_get_object(ST(i));
                if (! data) {
                    lasso_release_list_of_gobjects(obj->any);
                    croak("an element cannot be converted to an LassoNode*");
                }
                lasso_list_add_gobject(obj->any, data);
            }
            XSRETURN(0);
        } else {
            RETVAL = obj->any;
        }
    OUTPUT:
        RETVAL

            
