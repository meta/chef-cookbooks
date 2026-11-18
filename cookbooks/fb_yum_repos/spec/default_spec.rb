# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2021-present, Facebook, Inc.
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
#

require 'chef'
require_relative '../libraries/yum_repos_helpers.rb'

describe FB::YumRepos do
  context 'gen_config_value' do
    it 'renders a string value as-is' do
      expect(FB::YumRepos.gen_config_value('foo', 'bar')).to eq('bar')
    end

    it 'renders a regular boolean for a true value' do
      expect(FB::YumRepos.gen_config_value('baz', true)).to eq('True')
    end

    it 'renders a regular boolean for a false value' do
      expect(FB::YumRepos.gen_config_value('baz', false)).to eq('False')
    end

    it 'renders a numeric boolear as a number for a true value' do
      expect(FB::YumRepos.gen_config_value('gpgcheck', true)).to eq('1')
    end

    it 'renders a numeric boolear as a number for a false value' do
      expect(FB::YumRepos.gen_config_value('gpgcheck', false)).to eq('0')
    end
  end

  # MetalOS writes dnf.conf at provisioning; any byte of difference makes chef
  # rewrite it and flush all DNF metadata on firstboot.
  context 'yum.conf.erb' do
    let(:rendered) do
      context = Chef::Mixin::Template::TemplateContext.new(
        :config => { 'main' => { 'gpgcheck' => true } },
        :repos => {
          'group' => {
            'repos' => {
              'b' => { 'baseurl' => 'https://b', 'gpgkey' => 'k' },
              'a' => { 'baseurl' => 'https://a', 'gpgkey' => 'k' },
            },
          },
        },
      )
      context[:node] = double('node', :centos? => true)
      context.render_template_from_string(
        File.read(File.join(__dir__, '../templates/default/yum.conf.erb')),
      )
    end

    it 'does not end with a newline' do
      expect(rendered).to end_with("\nname=b")
    end

    it 'separates sections with a blank line' do
      expect(rendered).to include("name=a\n\n[b]\n")
    end
  end
end
