{ inputs, cell }:

let readYAML' = _: _: inputs.std.lib.ops.readYAML;
in {

  argocrds = with inputs.std.inputs.haumea.lib;
    load {
      src = inputs.nixpkgs.argocd.src + "/manifests/crds";
      loader = [ (matchers.regex "^.+\\.(yaml|yml)" readYAML') ];
    };

}
