# This file is responsible for configuration values that must appear at runtime
import Config

# config :attercop,
#   foo: "bar"

if config_env() == :prod do
end

if config_env() == :dev do
end
