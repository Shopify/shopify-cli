# Generated from shopify-cli-1.0.1.gem by gem2rpm -*- rpm-spec -*-
%define rbname shopify-cli
%define version 1.0.1
%define release 1
%define _rpmdir ./build
%define _target_os linux

Summary: Shopify CLI helps you build Shopify apps faster.
Name: ruby-gems-%{rbname}

Version: %{version}
Release: %{release}
Group: Development/Ruby
License: Distributable
URL: https://shopify.github.io/shopify-app-cli/
# Make sure the spec template is included in the SRPM
Source0: ruby-gems-%{rbname}.spec.in
# Requires: ruby [">= 2.3.0"]
Requires: ruby >= 2.3.0
BuildArch: noarch
Provides: ruby(Shopify-cli) = %{version}

%description
Shopify CLI helps you build Shopify apps faster. It quickly scaffolds Node.js
and Ruby-on-Rails embedded apps. It also automates many common tasks in the
development process and lets you quickly add popular features, such as billing
and webhooks.


%prep
%setup -T -c

%build

%post
gem install shopify-cli

%preun
gem uninstall shopify-cli

%clean

%files

%changelog
