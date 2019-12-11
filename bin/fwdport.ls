require! {
  fs
  os
  path
  yamlfile
}

{execSync} = require 'child_process'
homedir = os.homedir()

do ->
  config_file_path = path.join(homedir, '.fwdport.yaml')
  if not fs.existsSync(config_file_path)
    console.log 'need file ' + config_file_path
    return
  config_data = yamlfile.readFileSync config_file_path
  if not config_data?
    console.log 'file ' + config_file_path + ' is not a valid YAML or JSON file'
    return
  {host, port} = config_data
  if not host?
    console.log 'file ' + config_file_path + ' is missing field "host"'
    return

  ports_to_forward = []
  for x in process.argv[2 to]
    if x.includes('help')
      console.log 'arguments must be integers (the ports to forward)'
      console.log 'received arguments:'
      console.log process.argv
      console.log 'expected arguments (example):'
      console.log [process.argv[1], '8080', '5000'].join(' ')
      console.log 'can also include host name (example):'
      console.log [process.argv[1], '8080', 'dell'].join(' ')
      console.log 'can also include pairs of origin:target (example):'
      console.log [process.argv[1], '8080:8889', 'dell'].join(' ')
      return
    if x.includes(':')
      [portnum_origin, portnum_target] = x.split(':')
      portnum_origin = parseInt portnum_origin
      portnum_target = parseInt portnum_target
      ports_to_forward.push [portnum_origin, portnum_target]
      continue
    if isNaN x
      host = x
      continue
    portnum_origin = parseInt x
    ports_to_forward.push [portnum_origin, portnum_origin]
  ssh_command = "ssh "
  if port?
    ssh_command += '-p ' + port + ' '
  ssh_command += ["-L #{portnum_target}:localhost:#{portnum_origin}" for [portnum_origin, portnum_target] in ports_to_forward].join(' ') + " " + host
  console.log ssh_command
  execSync ssh_command, {stdio: 'inherit'}
