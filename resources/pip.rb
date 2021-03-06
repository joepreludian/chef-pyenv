#
# Cookbook:: pyenv
# Resource:: pip
#
# Author:: Darwin D. Wu <darwinwu67@gmail.com>
#
# Copyright:: 2018, Darwin D. Wu
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
provides :pyenv_pip

property :package_name, String, name_property: true
property :virtualenv,   String
property :version,      String
property :user,         String
property :options,      String
property :requirement,  [true, false], default: false
property :editable,     [true, false], default: false

action :install do
  install_mode = if new_resource.requirement
                   '--requirement'
                 elsif new_resource.editable
                   '--editable'
                 else
                   ''
                 end

  install_target = if new_resource.version
                     "#{new_resource.package_name}==#{new_resource.version}"
                   else
                     new_resource.package_name.to_s
                   end

  pip_args = "install #{new_resource.options} #{install_mode} #{install_target}"

  # without virtualenv, install package with system's pip
  command = if new_resource.virtualenv
              "#{new_resource.virtualenv}/bin/pip #{pip_args}"
            else
              "pip #{pip_args}"
            end

  pyenv_script new_resource.package_name do
    code command
    user new_resource.user if new_resource.user
  end
end

action :uninstall do
  uninstall_mode = if new_resource.requirement
                     '--requirement'
                   else
                     ''
                   end

  pip_args = ["uninstall --yes #{new_resource.options}",
              "#{uninstall_mode} #{new_resource.package_name}"].join

  # without virtualenv, uninstall package with system's pip
  command = if new_resource.virtualenv
              "#{new_resource.virtualenv}/bin/pip #{pip_args}"
            else
              "pip #{pip_args}"
            end

  pyenv_script new_resource.package_name do
    code command
    user new_resource.user if new_resource.user
  end
end
