package  {
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import fl.transitions.TweenEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import fl.motion.easing.Linear;
	import flash.events.Event;
	
	public class ConvexHullHelper extends MovieClip {

		public function ConvexHullHelper() {
		}
		
		// point and line arrays
		var points:Array = new Array();
		var lines:Array = new Array();
		
		// point functions
		function comparePoints(p1:Point, p2:Point):int {
			if (p1.x > p2.x)
				return 1;
			if (p1.x < p2.x)
				return -1;
			if (p1.y > p2.y)
				return 1;
			if (p1.y < p2.y)
				return -1;
			return 0;
		}
		function CCW(p1:Point, p2:Point, p3:Point):int {
			var det = p1.x*(p2.y-p3.y)-p2.x*(p1.y-p3.y)+p3.x*(p1.y-p2.y);
		
			if (det < 0)
				return -1;
			else if (det > 0)
				return 1;
			else
				return 0;
		}
		function sqDist(p1:Point, p2:Point):int {
			var x_dist = p2.x - p1.x;
			var y_dist = p2.y - p1.y;
			return x_dist * x_dist + y_dist * y_dist;
		}
		function compLineDist(lp1:Point, lp2:Point, p1:Point, p2:Point):int {
			var A = lp1.y - lp2.y;
			var B = lp2.x - lp1.x;
			var C = lp1.y * (lp1.x-lp2.x) + lp1.x * (lp2.y-lp1.y);
		
			// numerators of point-line distance
			var num1 = Math.abs(A * p1.x + B * p1.y + C);
			var num2 = Math.abs(A * p2.x + B * p2.y + C);
		
			if (num1 > num2)
				return 1;
			if (num1 < num2)
				return -1;
			return 0;
		}

		// message functions
		function printMessage(msg:String) {
			trace(msg);
		}
		function appendMessage(msg:String) {
			trace(msg);
		}

		
		/**************************************************************
		 * click event listeners                                      *
		 **************************************************************/
		
		/*click_area_btn.addEventListener(MouseEvent.CLICK, clickE);
		function clickE(e:MouseEvent) {
			// remove lines, actions, and labels
			removeLines();
			removeActions();
			removeLabels();
		
			// get coordinates
			var x_coor:int = e.stageX;
			var y_coor:int = e.stageY;
		
			// clear message
			printMessage("");
		
			// ignore if point already in set
			for (var i = 0; i < points.length; i++) {
				if (points[i].x == x_coor && points[i].y == y_coor) {
					printMessage("Point already in set.");
					return;
				}
			}
		
			// add point to set
			var point:Point = new Point();
			point.x = x_coor;
			point.y = y_coor;
			points.push(point);
			addChild(point);
			addChild(click_area_btn);
		}
		
		clear_mc.addEventListener(MouseEvent.CLICK, clearE);
		function clearE(e:MouseEvent) {
			// remove lines and actions
			removeLines();
			removeActions();
		
			// remove all points
			var point:Point;
			while ((point = points.pop()) != null)
				removeChild(point);
			printMessage("Points cleared.");
		}
		
		ch_mc.addEventListener(MouseEvent.CLICK, chE);
		function chE(e:MouseEvent) {
			// remove lines, actions, and labels
			removeLines();
			removeActions();
			removeLabels();
		
			// run algorithm
			switch(alg_mc.selectedItem.data) {
				case "gs":
					GrahamScan(points, true);
					break;
				case "jm":
					JarvisMarch(points, true);
					break;
				case "chan":
					Chan(points, true);
					break;
				case "qh":
					QuickHull(points, true);
					break;
				case "dc":
					DivideAndConquer(points, true);
					break;
			}
		}*/
		
		/**************************************************************
		 * convex hull algorithms                                     *
		 **************************************************************/
		
		function GrahamScan(points:Array, show_ch:Boolean = false):Array {
			// special cases: 0 or 1 point
			if (points.length == 0)
				return [];
			if (points.length == 1)
				return [points[0]];
		
			// find index of leftmost point
			var left_idx = 0;
			for (var i = 1; i < points.length; i++) {
				if (comparePoints(points[i], points[left_idx]) < 0)
					left_idx = i;
			}
		
			// sort points by angle to leftmost point
			var left:Point = points[left_idx];
			var sorted:Array = new Array();
			for (i = 0; i < points.length; i++) {
				if (i != left_idx)
					sorted.push(points[i]);
			}
			var gr_p:Point = points[!left_idx+0];
			for (i = !left_idx+1; i < points.length; i++) {
				if (i != left_idx) {
					var curr_p:Point = points[i];
					var gr_cmp = (gr_p.y - left.y) * (curr_p.x - left.x);
					var curr_cmp = (curr_p.y - left.y) * (gr_p.x - left.x);
					if (curr_cmp > gr_cmp)
						gr_p = curr_p;
				}
			}
			function comp(p1:Point,p2:Point):int {
				var cmp1 = (p1.y - left.y) * (p2.x - left.x);
				var cmp2 = (p2.y - left.y) * (p1.x - left.x);
				if (cmp1 < cmp2)
					return -1;
				else if (cmp1 > cmp2)
					return 1;
				else {	// collinear case
					gr_cmp = (gr_p.y - left.y) * (p1.x - left.x);
					curr_cmp = (p1.y - left.y) * (gr_p.x - left.x);
					if (gr_cmp == curr_cmp) {
						if (sqDist(p1,left) < sqDist(p2,left))
							return 1;
						else
							return -1;
					}
					else {
						if (sqDist(p1,left) < sqDist(p2,left))
							return -1;
						else
							return 1;
					}
				}
			}
			sorted.sort(comp);
		
			// pushed sorted list of vertices onto input stack
			var input:Array = sorted.reverse();
		
			// run graham scan

			var output:Array = new Array();
			output.push(left);
			output.push(input.pop());
			
			while (input.length > 0) {
				var point:Point = input.pop();
				var ccw;
				while ((ccw = CCW(output[output.length-2],output[output.length-1],point)) < 0) {
					output.pop();
				}
				output.push(point);
			}
		
			// return point array as output
			return output;
		}
		
		function JarvisMarch(points:Array, show_ch:Boolean = false):Array {
			// special cases: 0 or 1 points
			if (points.length == 0)
				return [];
			if (points.length == 1)
				return [points[0]];
		
			// find index of leftmost point
			var point:Point = points[0];
			for (var i = 1; i < points.length; i++) {
				if (comparePoints(points[i], point) < 0)
					point = points[i];
			}
			var output:Array = [point];
		
			while (true) {
				// find rightmost
				point = null;
				for (i = 0; i < points.length; i++) {
					if (points[i] == output[output.length-1])
						continue;
					if (point == null) {
						point = points[i];
						continue;
					}
					if (right(output.length < 2 ? null : output[output.length-2], output[output.length-1], points[i], point) > 0)
						point = points[i];
				}
				
				if (point == output[0])
					break;
				output.push(point);
			}
			
			return output;
		}
		
		function Chan(points:Array, show_ch:Boolean = false):Array {
			// special cases: 0 or 1 points
			var n = points.length;
			if (n == 0)
				return [];
			if (n == 1)
				return [points[0]];
		
			// square the guess of h each iteration
			var prev_m:int = -1;
			for (var m = 2; m != null; m = m == n ? null : Math.min(m*m,n)) {
				
				// partition points
				var parts:Array = new Array(Math.ceil(n/m));
				var curr_part = 0;
				var idx = 0;
				for (var i = 0; i < n; i++) {
					// go to next partition
					if (idx == m) {
						curr_part++;
						idx = 0;
					}
					// initiaze new partition
					if (idx == 0)
						parts[curr_part] = new Array(Math.min(m,n-i));
					// add point to partition
					parts[curr_part][idx] = points[i];
					idx++;
				}
				// run graham scan on each partition
				var ch:Array = new Array(parts.length);
				for (curr_part = 0; curr_part < parts.length; curr_part++) {
					var ch_arr:Array = ch[curr_part] = GrahamScan(parts[curr_part]);
					
				}
				// find leftmost point
				var ch_idx = 0;
				idx = 0;
				for (i = 1; i < ch.length; i++) {
					if (comparePoints(ch[i][0], ch[ch_idx][0]) < 0)
						ch_idx = i;
				}
				var output:Array = new Array();
				output.push(ch[ch_idx][0]);
				// run jarvis march, stop if we realize m < h

				for (i = 1; i <= m; i++) {
					// find rightmost point
					var ch_right = null;
					var right_idx;
					for (var curr_ch = 0; curr_ch < ch.length; curr_ch++) {
						var curr_right_idx;
						if (curr_ch == ch_idx) {
							if (ch[ch_idx].length == 1)
								continue;
							curr_right_idx = (idx + 1) % ch[ch_idx].length;
						}
						else
							curr_right_idx = rightmost(output.length < 2 ? null : output[output.length-2], output[output.length-1], ch[curr_ch]);
						
						if (ch_right == null || right(output.length < 2 ? null : output[output.length-2], output[output.length-1], ch[curr_ch][curr_right_idx], ch[ch_right][right_idx]) > 0) {
							ch_right = curr_ch;
							right_idx = curr_right_idx;
						}
					}
					
					// if found starting point, done
					if (ch[ch_right][right_idx] == output[0]) {
						
						return output;
					}
					// add to convex hull
					output.push(ch[ch_right][right_idx]);
					ch_idx = ch_right;
					idx = right_idx;
				}
				prev_m = m;
			}
			throw new Error("Failed to find convex hull.");
		}
		
		function QuickHull(points:Array, show_ch:Boolean = false):Array {
			// special cases: 0 or 1 points
			var n = points.length;
			if (n == 0)
				return [];
			if (n == 1)
				return [points[0]];
		
			// find left, right, top, and bottom points
			var left:Point = points[0];
			var right:Point = points[0];
			var top:Point = points[0];
			var bottom:Point = points[0];
			for (var i = 1; i < points.length; i++) {
				if (points[i].x < left.x)
					left = points[i];
				if (points[i].x > right.x)
					right = points[i];
				if (points[i].y < bottom.y)
					bottom = points[i];
				if (points[i].y > top.y)
					top = points[i];
			}
		
			// draw lines
			var lb_line:MovieClip = null;
			var rb_line:MovieClip = null;
			var rt_line:MovieClip = null;
			var lt_line:MovieClip = null;
			
			// split points into 4 sets (4 outer triangles), discard interior
			var left_bottom:Array = new Array();
			var right_bottom:Array = new Array();
			var right_top:Array = new Array();
			var left_top:Array = new Array();
			for (i = 0; i < points.length; i++) {
				if (points[i] != left && points[i] != top && CCW(left,top,points[i]) >= 0)
					left_top.push(points[i]);
				else if (points[i] != top && points[i] != right && CCW(top,right,points[i]) >= 0)
					right_top.push(points[i]);
				else if (points[i] != right && points[i] != bottom && CCW(right,bottom,points[i]) >= 0)
					right_bottom.push(points[i]);
				else if (points[i] != bottom && points[i] != left && CCW(bottom,left,points[i]) >= 0)
					left_bottom.push(points[i]);
			}
		
			// recursively solve each triangle and concatenate
			var output:Array = [left];
			if (left != bottom)
				output = output.concat(qh_helper(left,bottom,lb_line,left_bottom)).concat([bottom]);
			if (bottom != right)
				output = output.concat(qh_helper(right,bottom,rb_line,right_bottom)).concat([right]);
			if (right != top)
				output.concat(qh_helper(right,top,rt_line,right_top)).concat([top]);
			if (top != left)
				output.concat(qh_helper(left,top,lt_line,left_top));
		
			// recursively computes convex hull of points compared to a line
			function qh_helper(lp1:Point, lp2:Point, line:MovieClip, pts:Array):Array {
				// base case
				if (pts.length == 0)
					return [];
				// find farthest point from line
				var fp:Point = pts[0];
				for (var i = 1; i < pts.length; i++) {
					if (compLineDist(lp1,lp2,pts[i],fp) > 0)
						fp = pts[i];
				}
				// draw new lines
				var l1:MovieClip = null;
				var l2:MovieClip = null;
				
				// space case: all points are on line
				if (CCW(lp1,lp2,fp) == 0) {
					function comp(p1:Point, p2:Point):int {
						if (sqDist(lp1,p1) > sqDist(lp1,p2))
							return 1;
						return 0;
					}
					return pts.sort(comp);
				}
				// find points on side 1
				var ccw = CCW(lp1,fp,lp2);
				var s1:Array = new Array();
				for (i = 0; i < pts.length; i++) {
					if (pts[i] != fp && CCW(lp1,fp,pts[i]) != ccw)
						s1.push(pts[i]);
				}
				// find points on side 2
				ccw = CCW(lp2,fp,lp1);
				var s2:Array = new Array();
				for (i = 0; i < pts.length; i++) {
					if (pts[i] != fp && CCW(lp2,fp,pts[i]) != ccw)
						s2.push(pts[i]);
				}
				return qh_helper(lp1,fp,l1,s1).concat([fp]).concat(qh_helper(lp2,fp,l2,s2));
			}
		
			return output;
		}
		
		function DivideAndConquer(points:Array, show_ch:Boolean = false):Array {
			// special cases: 0 or 1 points
			var n = points.length;
			if (n == 0)
				return [];
			if (n == 1)
				return [points[0]];
		
			// sort from left to right
			var sorted:Array = new Array();
			for (var i = 0; i < points.length; i++)
				sorted.push(points[i]);
			sorted.sort(comparePoints);
		
			// recursive helper function
			function dc_helper(low:int, high:int):Array {
				// base case
				if (low == high)
					return [[sorted[low]],show_ch ? [] : null];
				// split in middle and solve each half
				var mid:int = Math.floor((low + high)/2);
				var left_arr:Array = dc_helper(low,mid);
				var left:Array = left_arr[0];
				var left_lines:Array = left_arr[1];
				var right_arr:Array = dc_helper(mid+1,high);
				var right:Array = right_arr[0];
				var right_lines:Array = right_arr[1];
				// comparator functions
				function compLT(p1:Point, p2:Point):int {
					if (p1.x > p2.x)
						return 1;
					if (p1.x < p2.x)
						return -1;
					if (p1.y > p2.y)
						return 1;
						return -1;
				}
				function compLB(p1:Point, p2:Point):int {
					if (p1.x > p2.x)
						return 1;
					if (p1.x < p2.x)
						return -1;
					if (p1.y < p2.y)
						return 1;
					return -1;
				}
				function compRT(p1:Point, p2:Point):int {
					if (p1.x < p2.x)
						return 1;
					if (p1.x > p2.x)
						return -1;
					if (p1.y > p2.y)
						return 1;
					return -1;
				}
				function compRB(p1:Point, p2:Point):int {
					if (p1.x < p2.x)
						return 1;
					if (p1.x > p2.x)
						return -1;
					if (p1.y < p2.y)
						return 1;
					return -1;
				}
				function getMax(arr:Array, comp:Function):int {
					var max:int = 0;
					for (var i = 1; i < arr.length; i++) {
						if (comp(arr[i],arr[max]) > 0)
							max = i;
					}
					return max;
				}
				var output:Array = new Array();
				// find top and bottom tangents
				var left_top:int = getMax(left, compLT);
				var left_bottom:int = getMax(left, compLB);
				var right_top:int = getMax(right, compRT);
				var right_bottom:int = getMax(right, compRB);
				var left_updated:Boolean = false;
				var right_updated:Boolean = false;
				do {
					var updated:Boolean = false;
					for (i = (left_top+1)%left.length; CCW(right[right_top],left[left_top],left[i]) < 0; i = (i+1)%left.length) {
						left_top = i;
						left_updated = updated = true;
					}
					for (i = (right_top+right.length-1)%right.length; CCW(left[left_top],right[right_top],right[i]) > 0; i = (i+right.length-1)%right.length) {
						right_top = i;
						right_updated = updated = true;
					}
				} while (updated);
				do {
					updated = false;
					for (i = (left_bottom+left.length-1)%left.length; CCW(right[right_bottom],left[left_bottom],left[i]) > 0; i = (i+left.length-1)%left.length) {
						left_bottom = i;
						left_updated = updated = true;
					}
					for (i = (right_bottom+1)%right.length; CCW(left[left_bottom],right[right_bottom],right[i]) < 0; i = (i+1)%right.length) {
						right_bottom = i;
						right_updated = updated = true;
					}
				} while (updated);
				
				// walk around left side
				output.push(left[left_top]);
				if (!(left_updated && left_top == left_bottom)) {
					for (var i = (left_top+1)%left.length; i != left_bottom; i = (i+1)%left.length)
						output.push(left[i]);
					if (left_top != left_bottom)
						output.push(left[left_bottom]);
				}
				// walk around right side
				output.push(right[right_bottom]);
				if (!(right_updated && right_top == right_bottom)) {
					for (i = (right_bottom+1)%right.length; i != right_top; i = (i+1)%right.length)
						output.push(right[i]);
					if (right_top != right_bottom)
						output.push(right[right_top]);
				}
				var lines:Array = null;
				
				return [output,lines];
			}
			var ch_res:Array = dc_helper(0,sorted.length-1);
			
			return ch_res[0];
		}
		
		/**************************************************************
		 * convex hull helpers                                        *
		 **************************************************************/
		
		function right(prev_p:Point, p:Point, p1:Point, p2:Point):int {
			var ccw = CCW(p2, p, p1);
			if (ccw == 0) {
				// if entirely collinear and either is on wrong side, return other
				if (prev_p != null && CCW(prev_p,p,p1) == 0) {
					var prev_dist = sqDist(prev_p, p1);
					var curr_dist = sqDist(p, p1);
					if (curr_dist > prev_dist)
						return -1;
					prev_dist = sqDist(prev_p, p2);
					curr_dist = sqDist(p, p2);
					if (curr_dist > prev_dist)
						return 1;
				}
				// pick closer point
				var dist1 = sqDist(p, p1);
				var dist2 = sqDist(p, p2);
				if (dist1 < dist2)
					return 1;
				else
					return -1;
			}
			else
				return ccw;
		}
		function rightmost(prev_p:Point, p:Point, points:Array) {
			var low = 0;
			var high = points.length - 1;
			while (low != high) {
				// special case: 2 points left
				if (low+1 == high) {
					if (right(prev_p,p,points[low],points[high]) > 0)
						return low;
					else
						return high;
				}
				// split in middle, eliminate half
				var mid = Math.ceil((low + high) / 2);
				if (right(prev_p,p,points[mid],points[low]) > 0) {
					if (right(prev_p,p,points[mid-1],points[mid]) > 0) {
						low = low + 1;
						high = mid - 1;
						continue;
					}
					if (right(prev_p,p,points[mid+1],points[mid]) > 0) {
						low = mid + 1;
						continue;
					}
					return mid;
				}
				else {
					if (right(prev_p,p,points[high],points[low]) > 0) {
						low = mid + 1;
						continue;
					}
					if (right(prev_p,p,points[low+1],points[low]) > 0) {
						low = low + 1;
						high = mid - 1;
						continue;
					}
					return low;
				}
			}
			// left with only 1 point, the rightmost
			return low;
		}
		
		/**************************************************************
		 * action queue functions                                     *
		 **************************************************************/
		
		var curr_action;
		var curr_event;
		var actions:Array = new Array();
		var args:Array = new Array();
		var listen_events:Array = new Array();
		function addAction(action:Function, arg, finish_event) {
			if (curr_action == null) {
				if (finish_event == null)
		
					action(arg);
				else {
					curr_action = action(arg);
					curr_event = finish_event;
					curr_action.addEventListener(finish_event, actionFinished);
				}
			}
			else {
				actions.push(action);
				args.push(arg);
				listen_events.push(finish_event);
			}
		}
		function removeActions() {
			if (curr_action != null) {
				curr_action.removeEventListener(curr_event, actionFinished);
				curr_action = null;
				actions = new Array();
				args = new Array();
				listen_events = new Array();
			}
		}
		
		function actionFinished(e:Event) {
			// reverse arrays (so we pop from front)
			actions = actions.reverse();
			args = args.reverse();
			listen_events = listen_events.reverse();
		
			// pop next action until need to wait
			var do_next:Boolean = true;
			while (do_next) {
				if (actions.length == 0) {
					curr_action = null;
					do_next = false;
				}
				else {
						curr_action = (actions.pop())(args.pop());
						curr_event = listen_events.pop();
						if (curr_event != null) {
							curr_action.addEventListener(curr_event, actionFinished);
							do_next = false;
						}
				}
			}
		
			// reverse arrays back to normal
			actions = actions.reverse();
			args = args.reverse();
			listen_events = listen_events.reverse();
		}

	}
	
}
