#!/bin/sh

echo "Only CentOS 7 and Ubuntu 18 is supported..."
if which dpkg 1>/dev/null 2>&1; then package_type=deb && echo "true"
elif which rpm 1>/dev/null 2>&1; then package_type=rpm && echo "true"
fi
echo "Removing Currently installed Zabbix Agent"
if which zabbix_agentd 1>/dev/null 2>&1 && which dpkg 1>/dev/null 2>&1; then apt remove zabbix-agent -y && rm -f /etc/apt/sources.list.d/zabbix.list
elif which rpm 1>/dev/null 2>&1 && which zabbix_agentd 1>/dev/null 2>&1; then yum remove zabbix-agent -y && yum-config-manager --disable zabbix
fi

host="$(hostname)"
echo
echo "Installing Zabbix Agent Version 3.4.15"
echo
case "$package_type" in
  rpm)
  yum install http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-agent-3.4.15-1.el7.x86_64.rpm -y
  echo
  echo "Changing Configuration..."
  echo
  grep -rl '127.0.0.1' /etc/zabbix/zabbix_agentd.conf | xargs sed -i 's/127.0.0.1/"Zabbix server ip"/g' #Change the zabbix server IP.
  grep -rl '# Timeout=3' /etc/zabbix/zabbix_agentd.conf | xargs sed -i 's/# Timeout=3/Timeout=3/g'
  grep -rl "Hostname=Zabbix server" /etc/zabbix/zabbix_agentd.conf | xargs sed -i "s/Hostname=Zabbix server/Hostname=$host/g"
  echo
  echo "Restarting and enabling onboot start"
  echo
  systemctl restart zabbix-agent && systemctl enable zabbix-agent
  echo
  echo "Installation is completed... Zabbix agent is running on Port 10050"
  netstat -ntpl | grep zabbix
  echo
  echo "Log Output:"
  tail /var/log/zabbix/zabbix_agentd.log
  ;;
  deb)
  wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.15-1%2Bbionic_amd64.deb
  dpkg -i zabbix-agent_3.4.15-1+bionic_amd64.deb
  echo
  echo "Changing Configuration..."
  echo
  grep -rl '127.0.0.1' /etc/zabbix/zabbix_agentd.conf | xargs sed -i 's/127.0.0.1/"Zabbix server ip"/g' #Change the zabbix server IP.
  grep -rl '# Timeout=3' /etc/zabbix/zabbix_agentd.conf | xargs sed -i 's/# Timeout=3/Timeout=3/g'
  grep -rl "Hostname=Zabbix server" /etc/zabbix/zabbix_agentd.conf | xargs sed -i "s/Hostname=Zabbix server/Hostname=$host/g"
  echo
  echo "Restarting and enabling onboot start"
  systemctl restart zabbix-agent && systemctl enable zabbix-agent
  echo
  echo
  echo "Installation is completed... Zabbix agent is running on Port 10050"
  netstat -ntpl | grep zabbix
  echo
  echo "Log Output"
  tail /var/log/zabbix/zabbix_agentd.log
  ;;
  *)
  ;;
esac
