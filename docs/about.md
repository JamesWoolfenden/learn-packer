# About

## Author: James Woolfenden

[LinkedIn](https://www.linkedin.com/jameswoolfenden/)

## Bio

I'm currently working as a Solution Principal for Slalom and based out of London.
I have a bit of experience in the DevOps field, I have worked for a number of consultancies
directly and indirectly.

## Why

When I started in this field we hardly if ever thought about Servers. I was
working in application development, we made applications and almost as an
afterthought we made installers.

When we were ready, we burnt the installers to CD or even DVD, and we were done
and waited for QA.

If our effort ever passed QA we made went "GOLD MASTER" or Release to
Manufacture (RTM). Releases took months.

In order to test our applications, we needed a known clean state, and to achieve
this clean slate we used tools like Norton Ghost to reset our disks and our OS.
I could then test the installer and applications again, and more importantly we
could repeat.

I started writing scripts to try an automate this process, and to ensure that
the process was repeatable. Later on the tools changed and it was VMs against
VMWare. With VMWare came snapshots and scripting the installation of components,
.dot net frameworks and drivers. I wrote a lot of scripts. The scripts started
getting complex and then we started making sure that our scripts were
Idempotent.

Idempotent is defined by the OED as "Denoting an element of a set which is
unchanged in value when multiplied or otherwise operated on by itself.", in this
context and layman terms, it's designed to be re-runnable.

I wrote a lot of Idempotent scripts too (bash, Ant, MSBuild and PowerShell
mostly). Then Puppet and Chef arrived, the First Generation of "DevOps" Tooling.
This helped give a framework to work with - a DSL or a Domain Specific Language.
We also has to install a lot of agents, and master control servers as well. We
shared more and we wrote less, but Ruby now.

It was getting easy to make servers and easier to make New Environments. I could
make new environments reliably and I could also decommission them, only being
limited by the infrastructure made available.

We started worrying about people changing our Servers (Ok Developers). How do we
Manage the Configuration and get to a know and recorded state, to fix the
"Drift". The difference from the desired state.

All these Puppet and Chef scripts looked to manage Drift, the tools would then
try to eliminate Drift and bring of environments back to the "Desired State".

We'll we'd try to that is, as it's only as Ruby code you wrote and the packages
they ran, how can you know all the cases/paths that describe how your state could
deviate?

Wouldn't it be better if I didn't have to? And besides some of these CM script
suites took a really long time to run, hours. If you wanted to add one new
package to a server or build agent. Agents everywhere. Running them in Prod was
just scary.

Then the Cloud.

This gave a common API to make our infrastructure against, limits? Just cost
now. Now we were using Ansible, all those agents were gone, but it still took
quite some time to make instances. Wouldn't it be better to make these in
advance? That would be quicker? What about just making new servers quickly from
AMIs instead and just the Environmental configuration at Launch?

When Ansible arrived we no longer had to add Agents/services but we still had to
wait while Ansible built or checked the images. You could use Ansible to make
AMIs directly but Packer is designed to solve just this problem.
Packer with scripts is great, Packer with Ansible is even easier.

What's even easier is when you find well explained samples.
