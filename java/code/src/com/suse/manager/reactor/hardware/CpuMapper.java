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
package com.suse.manager.reactor.hardware;

import com.redhat.rhn.domain.server.CPU;
import com.redhat.rhn.domain.server.CPUArch;
import com.redhat.rhn.domain.server.MinionServer;
import com.redhat.rhn.domain.server.ServerFactory;
import com.suse.manager.reactor.utils.ValueMap;
import com.suse.manager.webui.services.SaltGrains;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Get the CPU information from a minion an store it in the SUMA db.
 */
public class CpuMapper extends AbstractHardwareMapper<CPU> {

    // Logger for this class
    private static final Logger LOG = Logger.getLogger(CpuMapper.class);

    /**
     * The constructor
     * @param saltServiceInvoker a {@link SaltServiceInvoker} instance
     */
    public CpuMapper(SaltServiceInvoker saltServiceInvoker) {
        super(saltServiceInvoker);
    }

    @Override
    public CPU doMap(MinionServer server, ValueMap grains) {

        final CPU cpu = Optional.ofNullable(server.getCpu()).orElseGet(CPU::new);

        // os.uname[4]
        String cpuarch = grains.getValueAsString(SaltGrains.CPUARCH.getValue())
                .toLowerCase();

        if (StringUtils.isBlank(cpuarch)) {
            setError("Grain 'cpuarch' has no value");
            LOG.warn("Grain 'cpuarch' has no value for minion: " + server.getMinionId());
            return null;
        }

        ValueMap cpuinfo = saltInvoker.getCpuInfo(server.getMinionId())
                .map(ValueMap::new).orElseGet(ValueMap::new);
        // salt returns /proc/cpuinfo data

        // See hardware.py read_cpuinfo()
        if (CpuArchUtil.isX86(cpuarch)) {
            if (cpuarch.equals("x86_64")) {
                cpuarch = "x86_64";
            }
            else {
                cpuarch = "i386";
            }

            // /proc/cpuinfo -> model name
            cpu.setModel(getModel(grains.getValueAsString("cpu_model")));
            // some machines don't report cpu MHz
            cpu.setMHz(getMhz(cpuinfo.get("cpu MHz").flatMap(ValueMap::toString)
                    .orElse("-1")));
            cpu.setVendor(getVendor(cpuinfo, "vendor_id"));
            cpu.setStepping(getStepping(cpuinfo, "stepping"));
            cpu.setFamily(getFamily(cpuinfo, "cpu family"));
            cpu.setCache(getCache(cpuinfo, "cache size"));
            cpu.setBogomips(getBogomips(cpuinfo, "bogomips"));
            cpu.setFlags(getFlags(cpuinfo.getValueAsCollection("flags")
                    .map(c -> c.stream()
                        .map(e -> cpuinfo.toString(e))
                        .filter(Optional::isPresent)
                        .map(Optional::get)
                        .collect(Collectors.joining(" ")))
                    .orElse(null)));
            cpu.setVersion(getVersion(cpuinfo, "model"));

        }
        else if (CpuArchUtil.isPPC64(cpuarch)) {
            cpu.setModel(getModel(cpuinfo.getValueAsString("cpu")));
            cpu.setVersion(getVersion(cpuinfo, "revision"));
            cpu.setBogomips(getBogomips(cpuinfo, "bogompis"));
            cpu.setVendor(getVendor(cpuinfo, "machine"));
            cpu.setMHz(getMhz(StringUtils.substring(cpuinfo.get("clock")
                    .flatMap(ValueMap::toString)
                    .orElse("-1MHz"), 0, -3))); // remove MHz sufix
        }
        else if (CpuArchUtil.isS390(cpuarch)) {
            cpu.setVendor(getVendor(cpuinfo, "vendor_id"));
            cpu.setModel(getModel(cpuarch));
            cpu.setBogomips(getBogomips(cpuinfo, "bogomips per cpu"));
            cpu.setFlags(getFlags(cpuinfo.get("features")
                    .flatMap(ValueMap::toString).orElse(null)));
            cpu.setMHz("0");
        }
        else {
            cpu.setVendor(cpuarch);
            cpu.setModel(cpuarch);
        }

        CPUArch arch = ServerFactory.lookupCPUArchByName(cpuarch);
        cpu.setArch(arch);

        cpu.setNrsocket(grains.getValueAsLong("cpusockets").orElse(null));
        // Use our custom grain. Salt has a 'num_cpus' grain but it gives
        // the number of active CPUs not the total num of CPUs in the system.
        // On s390x this number of active and actual CPUs can be different.
        cpu.setNrCPU(grains.getValueAsLong("total_num_cpus").orElse(0L));

        if (arch != null) {
            // should not happen but arch is not nullable so if we don't have
            // the arch we cannot insert the cpu data
            cpu.setServer(server);
            server.setCpu(cpu);
        }

        return cpu;
    }

    private String getVendor(ValueMap cpuinfo, String key) {
        return cpuinfo.getValueAsString(key, 32);
    }

    private String getVersion(ValueMap cpuinfo, String key) {
        return cpuinfo.getValueAsString(key, 32);
    }

    private String getBogomips(ValueMap cpuinfo, String key) {
        return cpuinfo.getValueAsString(key, 16);
    }

    private String getCache(ValueMap cpuinfo, String key) {
        return cpuinfo.getValueAsString(key, 16);
    }

    private String getFamily(ValueMap cpuinfo, String key) {
        return cpuinfo.getValueAsString(key, 32);
    }

    private String getMhz(String value) {
        return StringUtils.substring(value, 0, 16);
    }

    private String getStepping(ValueMap cpuinfo, String key) {
        return cpuinfo.getValueAsString(key, 16);
    }

    private String getModel(String value) {
        return StringUtils.substring(value, 0, 32);
    }

    private String getFlags(String value) {
        return StringUtils.substring(value, 0, 2048);
    }


}
