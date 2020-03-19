resource "azurerm_api_management" "apim" {
  name                = "apim${var.environment}${var.base_name}"
  location            = var.region
  resource_group_name = var.rg_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name = "${var.sku_name}_${var.node_count}"
 
  dynamic "certificate" {
    for_each = var.ca_certificates

    content {
      encoded_certificate   = certificate.value.base64_encoded_certificate
      certificate_password  = certificate.value.certificate_password
      store_name            = certificate.value.store_name
    }
  }
  
  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML
  }

  tags = merge({
    environment = var.environment
    base        = var.base_name
  }, var.tags)
}

resource "azurerm_api_management_logger" "example" {
  name                = "apim${var.environment}${var.base_name}logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.rg_name

  application_insights {
    instrumentation_key = var.instrumentation_key
  }
}