#
# Author:: Ronald Doorn (<rdoorn@schubergphilis.com>)
# Cookbook Name:: firwall
# Provider:: zone_firewalld
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

include Chef::Mixin::ShellOut

action :set do
  if zone_isset?(@new_resource.name, @new_resource.target)
    Chef::Log.debug "Zone #{@new_resource.name} already set to #{new_resource.target} - skipping"
  else
    converge_by("Setting zone #{@new_resource.name} to #{new_resource.target}") do
      apply_zone(@new_resource.name, @new_resource.target)
    end
  end
end

private

def apply_zone(zone, target) # rubocop:disable MethodLength
  firewalld_command = 'firewall-cmd '
  firewalld_command << "--set-#{zone}-zone=#{target}"

  Chef::Log.debug("firewalld: #{firewalld_command}")
  shell_out!(firewalld_command)

  Chef::Log.info("#{@new_resource} #{@new_resource.zone} zone set to #{target}")
  new_resource.updated_by_last_action(true)
end

# TODO: currently only works when firewall is enabled
def zone_isset?(zone, target)
  
  firewalld_command = 'firewall-cmd '
  firewalld_command << "--get-#{zone}-zone"

  match = shell_out!(firewalld_command).stdout.lines.find do |line|
    line.chomp.rstrip =~ /#{target}/
  end

  Chef::Log.debug("firewalld: found existing zone for \"#{@new_resource.zone}\": \"#{match.strip}\"") if match

  !!match
end
