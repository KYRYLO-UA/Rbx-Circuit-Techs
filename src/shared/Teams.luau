local Teams = {}

Teams["Police"] = {
     Name = "Національна Поліція",
     ShortName = "НПУ",

     BrickColor = BrickColor.new("Cyan"),

     Permissions = {
          Paycheck = { {15182749, 0, 1000}, {15182749, 255, 10000} }, -- {groupId, groupRank, amount} / amount

          AutoMorphs = {"корд"},
          AvailableMorphs = { {15182749, 255, "корд"} } -- {groupId, groupRank, morphNameInMorphStorage}
     }
}

return Teams