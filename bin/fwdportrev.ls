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
  {host} = config_data
  if not host?
    console.log 'file ' + config_file_path + ' is missing field "host"'
    return

  ports_to_forward = []
  for x in process.argv[2 to]
    portnum = parseInt x
    if isNaN portnum
      console.log 'arguments must be integers (the ports to forward)'
      console.log 'received arguments:'
      console.log process.argv
      console.log 'expected arguments (example):'
      console.log [process.argv[0], '8080', '5000'].join(' ')
      return
    ports_to_forward.push portnum
  ssh_command = "ssh " + ["-R 0.0.0.0:#{portnum}:localhost:#{portnum}" for portnum in ports_to_forward].join(' ') + " " + host
  console.log ssh_command
  execSync ssh_command, {stdio: 'inherit'}
