resource "tls_private_key" "priv" {
  for_each = {
    for cert in local.certificates : "${cert.key}" => cert if cert.private_key == null
  }
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  for_each = {
    for cert in local.certificates : "${cert.key}" => cert if cert.certificate_body == null
  }
  private_key_pem = tls_private_key.priv[each.key].private_key_pem

  subject {
    common_name  = "${each.key}.sapphirehealth.org"
    organization = "Sapphire Health"
  }

  validity_period_hours = 525600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "acm_certificate" {
  for_each = {
    for cert in local.certificates : "${cert.key}" => cert
  }
  private_key      = each.value.private_key != null ? each.value.private_key : tls_private_key.priv[each.key].private_key_pem
  certificate_body = each.value.certificate_body != null ? each.value.certificate_body : tls_self_signed_cert.cert[each.key].cert_pem
  tags = merge({
    Name = each.value.name
    },
    each.value.tags
  )
}
