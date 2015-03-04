module.exports = args = {}
shortArgs = {
    'd': 'debug'
}
for i in process.argv
    continue unless i.indexOf('-') == 0
    matches = i.match(/^-([^-].*)$/)
    matchesLong = i.match(/^--([^=]*)=(.*)$/)
    matchesLongSwitch = i.match(/^--([^=]*)$/)
    if matches?.length
        tags = matches[1]
        for x in tags
            if shortArgs[x]
                long = shortArgs[x]
                args[long] = true
    else if matchesLong?.length
        args[matchesLong[1].toLowerCase()] = matchesLong[2]
    else if matchesLongSwitch?.length
        args[matchesLongSwitch[1].toLowerCase()] = true