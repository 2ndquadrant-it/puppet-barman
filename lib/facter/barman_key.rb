Facter.add('barman_key') do
  setcode do 
    system('[ -f ~barman/.ssh/id_rsa ] || su - barman -c "ssh-keygen -t rsa -P \"\" -q -f ~barman/.ssh/id_rsa"')
    Facter::Util::Resolution.exec('/bin/cat /var/lib/barman/.ssh/id_rsa.pub').chomp
  end
end
