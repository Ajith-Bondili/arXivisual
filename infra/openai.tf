# Azure OpenAI account plus its model deployments.
resource "azurerm_cognitive_account" "openai" {
  name                = "arxivisual-openai"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  kind                = "OpenAI"
  sku_name            = "S0"

  custom_subdomain_name         = "arxivisual-openai"
  public_network_access_enabled = true
}

# Main text + visual-QA model. gpt-6-luna (GA, no access request; Chat
# Completions, structured outputs, image input and reasoning_effort all
# supported) replaces gpt-5-mini, which retires 2027-02-09, at a lower
# per-token price. The apps reference this resource's name, so Terraform
# creates the deployment before pointing any app at it.
resource "azurerm_cognitive_deployment" "gpt_6_luna" {
  name                 = "gpt-6-luna"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-6-luna"
    version = "2026-09-22"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 250
  }

  rai_policy_name = "Microsoft.DefaultV2"
  # Stay on 2026-09-22 until that version retires, then upgrade instead of
  # failing every call (NoAutoUpgrade would stop the pipeline at retirement).
  version_upgrade_option = "OnceCurrentVersionExpired"
}

# Previous main model, kept (no cost while idle) so rollback is an env change.
# Retires 2027-02-09; delete after the gpt-6-luna cut-over has settled.
resource "azurerm_cognitive_deployment" "gpt_5_mini" {
  name                 = "gpt-5-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-5-mini"
    version = "2025-08-07"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 250
  }

  rai_policy_name        = "Microsoft.DefaultV2"
  version_upgrade_option = "OnceNewDefaultVersionAvailable"
}

# Voiceover text-to-speech model.
resource "azurerm_cognitive_deployment" "gpt_4o_mini_tts" {
  name                 = "gpt-4o-mini-tts"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini-tts"
    version = "2025-12-15"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 50
  }

  rai_policy_name        = "Microsoft.DefaultV2"
  version_upgrade_option = "OnceNewDefaultVersionAvailable"
}
