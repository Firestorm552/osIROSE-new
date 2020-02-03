#pragma once

#include "dataconsts.h"
#include "entity_system.h"

namespace Utils {
template <typename T>
void transfer_to_char(EntitySystem& entitySystem, RoseCommon::Entity entity, const T& packet) {
    entitySystem.send_to(entity, packet);
}
}
