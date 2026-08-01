/*
 *  RL78 arch-specific callbacks (tlib -> external).
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

/* Signals to the external interrupt controller that the interrupt with the
 * given index has been accepted (equivalent of qemu_set_irq(env->irq_ack)). */
void tlib_on_rl78_irq_ack(uint32_t index);
