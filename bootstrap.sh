#!/bin/bash
yum update -y
yum install ansible -y
cat <<EOF > /home/ec2-user/web.yml
- hosts: localhost
  become: true
  tasks:
    - name: Install Apache
      yum:
        name: httpd
        state: present
    - name: Enable and start service
      service:
        name: httpd
        state: started
        enabled: true
    - name: Change port
      replace:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^Listen 80'
        replace: 'Listen 8080'
    - name: Reload Apache
      service:
        name: httpd
        state: restarted
    - name: Add web content
      copy:
        dest: /var/www/html/index.html
        content: "<h1>Zantac Web Server running on 8080</h1>"
EOF

ansible-playbook /home/ec2-user/web.yml

