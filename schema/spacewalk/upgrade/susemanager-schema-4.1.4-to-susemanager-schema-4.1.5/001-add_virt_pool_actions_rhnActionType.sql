-- Copyright (c) 2020 SUSE LLC
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation.
--

insert into rhnActionType (id, label, name, trigger_snapshot, unlocked_only) (
    select 509, 'virt.pool_refresh', 'Refresh a virtual storage pool', 'N', 'N'
    from dual
    where not exists (select 1 from rhnActionType where id = 509)
);

insert into rhnActionType (id, label, name, trigger_snapshot, unlocked_only) (
    select 510, 'virt.pool_start', 'Starts a virtual storage pool', 'N', 'N'
    from dual
    where not exists (select 1 from rhnActionType where id = 510)
);
