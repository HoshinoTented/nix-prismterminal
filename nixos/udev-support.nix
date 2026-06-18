{
  stdenv,
  lib,
  prismterminal,
  writeTextFile,
  ...
}:

let
  kagamiVendor = "5d3e";

  hardwares = 
    [
      {
        name = "desu.life ARM IAP";
        idVendor = kagamiVendor;
        idProduct = "fa00";
      }
      {
        name = "Kagami Studio MeowpadV3";
        idVendor = kagamiVendor;
        idProduct = "f00c";
      }
    ];

  processRules = with lib; (hds:
    let
      sorted = sortOn (hd: [ hd.idVendor hd.idProduct]) hds;
      grouped = groupBy (hd: "${hd.idVendor}:${hd.idProduct}") sorted;
      flatten = mapAttrsToList (_: group:
        let fst = elemAt group 0; in
        {
          name = join ", " (map (hds: hds.name) group);
          inherit (fst) idProduct idVendor;
        }
      ) grouped;
    in flatten
  );

  generateRule = { name, idVendor, idProduct }: ''
    # ${name}
    KERNEL=="hidraw*", ATTRS{idVendor}=="${idVendor}", ATTRS{idProduct}=="${idProduct}", TAG+="uaccess"
  '';

  generateRules = hds: lib.join "\n" (map (hd: generateRule hd) hds);

  canonicalizeRule = hd: 
    let
      toHex = i: if lib.isInt i then lib.toHexString i else i;
      idVendor = lib.strings.toLower (toHex hd.idVendor);
      idProduct = lib.strings.toLower (toHex hd.idProduct);
    in
    {
      inherit (hd) name;
      inherit idVendor idProduct;
    };

  hardwaresType = lib.types.listOf (lib.types.submodule {
      options = lib.genAttrs [ "name" "idVendor" "idProduct" ] (_: lib.mkOption {
        type = lib.types.either lib.types.number lib.types.str;
      });
  });

  withExtra = extra:
    let
      extras = if lib.isList extra then extra else [ extra ];
      full = hardwares ++ extras;
      rules = generateRules (processRules (map canonicalizeRule full));
    in
      writeTextFile {
        name = "${prismterminal.pname}-udev-${prismterminal.version}";
        text = rules;
        destination = "/etc/udev/rules.d/70-prismterminal.rules";   # It is necessary that order is 70
      };
in
{
  inherit withExtra hardwaresType;
}