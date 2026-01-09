function battery --description "Show HID device battery status"
    for device in /sys/class/power_supply/hid-*-battery
        if test -e $device
            set model (cat $device/model_name 2>/dev/null; or echo "Unknown")
            set capacity (cat $device/capacity 2>/dev/null; or echo "?")
            set charge_status (cat $device/status 2>/dev/null; or echo "?")

            # Status icon
            switch $charge_status
                case Charging
                    set icon "⚡"
                case Discharging
                    set icon "🔋"
                case Full
                    set icon "✓"
                case '*'
                    set icon ""
            end

            echo "$model: $capacity% $icon $charge_status"
        end
    end
end
