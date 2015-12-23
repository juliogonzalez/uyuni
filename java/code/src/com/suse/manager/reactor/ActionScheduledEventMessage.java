/**
 * Copyright (c) 2015 SUSE LLC
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.suse.manager.reactor;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.action.Action;

/**
 * Event message for the {@link com.redhat.rhn.common.messaging.MessageQueue;} to signal
 * that a new {@link com.redhat.rhn.domain.action.server.ServerAction} has been stored.
 *
 * This event would then be handled by {@link ActionScheduledEventMessageAction} to
 * act on it and execute the action using Salt.
 */
public class ActionScheduledEventMessage implements EventMessage {

    private final Action action;

    /**
     * Create a new event about an action that was stored.
     *
     * @param minionIdIn minion to register
     */
    public ActionScheduledEventMessage(Action actionIn) {
        action = actionIn;
    }

    /**
     * Get the action.
     *
     * @return the action
     */
    public Action getAction() {
        return action;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toText() {
        return "ActionStoredEvent[action: " + action.toString() + "]";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Long getUserId() {
        return action.getSchedulerUser().getId();
    }
}
