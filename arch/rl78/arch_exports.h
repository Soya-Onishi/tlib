/*
 *  RL78 arch-specific exports (external -> tlib).
 *
 *  Copyright (c) Antmicro
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 */
#pragma once

#include <stdint.h>

/*
 * Inject an interrupt request coming from the (external) RL78 interrupt
 * controller. Unlike the generic tlib_set_irq(), this carries the vector
 * index and priority the RL78 core needs to evaluate nesting.
 *   enable != 0 : latch (index, priority) and assert CPU_INTERRUPT_HARD
 *   enable == 0 : clear the pending candidate
 */
void tlib_set_rl78_irq(int32_t index, int32_t priority, int32_t enable);
