locals {
    certificates = flatten([
        for cert_key, cert in var.certificates : {
            key = "${cert_key}"
            name = cert.name != null ? cert.name : "${var.name_prefixes["cert"]}${cert_key}${var.name_suffixes["cert"]}"
            private_key = cert.private_key
            certificate_body = cert.certificate_body
            tags = cert.tags
        }
    ])
}