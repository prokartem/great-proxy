// nomad-pack run --address="http://NOMAD-SERVER-IP:4646" --var-file=example.hcl .
protocols = [
    {
        name = "eth"
        providers = ["getblock", "alchemy", "infura", "quicknode"]
    }
]