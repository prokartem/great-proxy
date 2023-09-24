// nomad-pack run --address="http://NOMAD-SERVER-IP:4646" --var-file=vars.hcl .
protocols = [
    {
        name = "eth"
        providers = ["getblock", "alchemy", "infura"]
    },
    {
        name = "bsc"
        providers = ["getblock", "alchemy", "infura"]
    }
]