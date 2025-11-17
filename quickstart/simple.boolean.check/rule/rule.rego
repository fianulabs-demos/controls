package rule

# Define all possible result states as false by default
default fail = false
default notFound = false
default notRequired = false
default pass = false

import future.keywords

# The control passes if the value is true
pass if {
    input.detail.passed == true
}

# The control is not required if it fails but policy says optional
notRequired if {
    not pass
    data.required == false
}
