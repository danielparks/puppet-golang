# @summary Valid ensure values for `golang::installation`
type Golang::Ensure = Variant[Enum[present, latest, absent], Golang::Version]
