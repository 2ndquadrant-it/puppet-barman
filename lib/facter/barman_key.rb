Facter.add('barman_key') do
  setcode do 
    Etc.passwd { |x|
      if x.name == 'barman'
        system('[ -f ~barman/.ssh/id_rsa ] || su - barman -c "ssh-keygen -t rsa -P \"\" -q -f ~barman/.ssh/id_rsa"')
      end
    }
    if File.exists? '/var/lib/barman/.ssh/id_rsa.pub'
      Facter::Util::Resolution.exec('/bin/cat /var/lib/barman/.ssh/id_rsa.pub').chomp
    else
      ''
    end
  end
end
