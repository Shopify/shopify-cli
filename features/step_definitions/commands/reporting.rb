require "iniparse"

Then(/I can turn the reporting (.+)/) do |on_off|
  enable = case on_off
  when "on"
    true
  when "off"
    false
  else
    flunk("Invalid reporting #{on_off} value")
  end

  @container.exec_shopify("reporting", on_off)
  config_content = @container.capture("cat", @container_shopify_config_path).chomp
  document = IniParse.parse(config_content)
  config_value = document["analytics"]["enabled"]

  if enable
    assert config_value
  else
    refute config_value
  end
end
