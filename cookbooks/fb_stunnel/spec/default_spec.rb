# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2020-present, Facebook, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require './spec/spec_helper'

recipe 'fb_stunnel::default', :unsupported => [:mac_os_x] do |tc|
  let(:chef_run) { tc.chef_run }

  it 'renders the config and starts stunnel' do
    chef_run.converge('fb_systemd::reload', described_recipe) do |node|
      node.default['fb_stunnel']['config']['my_www'] = {
        'accept' => 443,
        'connect' => '127.0.0.1:8080',
      }
    end
    conf = chef_run.template('/etc/stunnel/fb_tunnel.conf')
    expect(ChefSpec::Renderer.new(chef_run, conf).content).
      to match(/^\[my_www\]$/)
    expect(chef_run).to start_service('stunnel')
    expect(chef_run).not_to stop_service('disable stunnel')
    expect(chef_run).not_to delete_file('remove /etc/stunnel/fb_tunnel.conf')
  end

  it 'stops stunnel and removes the config without sections' do
    chef_run.converge('fb_systemd::reload', described_recipe)
    expect(chef_run).not_to create_template('/etc/stunnel/fb_tunnel.conf')
    expect(chef_run).to delete_file('remove /etc/stunnel/fb_tunnel.conf')
    expect(chef_run).to stop_service('disable stunnel')
    expect(chef_run).to disable_service('disable stunnel')
    expect(chef_run).not_to start_service('stunnel')
  end
end
