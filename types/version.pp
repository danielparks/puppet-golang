# @summary A Go version
#
# Generally something like `'1.8.1'`, but may also be something like `'1.3rc1'`.
type Golang::Version = Pattern[/\A[1-9]\d*(\.\d+)*([a-z]+\d+)?\z/]
