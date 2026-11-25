# Copyright (c) Meta Platforms, Inc. and affiliates.
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

require './spec/spec_helper'

recipe 'fb_kea::default', :unsupported => [:mac_os_x] do |tc|
  let(:chef_run) do
    tc.chef_run
  end

  it 'enables both DHCP servers by default' do
    chef_run.converge(described_recipe)
    expect(chef_run).to render_file('/etc/kea/kea-dhcp4.conf')
    expect(chef_run).to render_file('/etc/kea/kea-dhcp6.conf')
    expect(chef_run).to start_service('kea-dhcp6-server')
    expect(chef_run).to_not stop_service('disable kea-dhcp6-server')
  end

  it 'stops kea-dhcp6-server when enable_dhcp6 is false' do
    chef_run.converge(described_recipe) do |node|
      node.default['fb_kea']['enable_dhcp6'] = false
    end
    expect(chef_run).to stop_service('disable kea-dhcp6-server')
    expect(chef_run).to_not stop_service('disable kea-dhcp4-server')
  end

  it 'only stops kea-dhcp4-server when enable_dhcp4 is false' do
    chef_run.converge(described_recipe) do |node|
      node.default['fb_kea']['enable_dhcp4'] = false
      node.default['fb_kea']['enable_dhcp6'] = true
    end
    expect(chef_run).to stop_service('disable kea-dhcp4-server')
    expect(chef_run).to start_service('kea-dhcp6-server')
    expect(chef_run).to_not stop_service('disable kea-dhcp6-server')
  end
end
