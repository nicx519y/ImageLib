/**
 * This class lets you play animated GIF files in AS3
 * @author Thibault Imbert (bytearray.org)
 * @version 0.6
 */

package org.bytearray.gif.player
{
	import flash.events.TimerEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.IOErrorEvent;
	import flash.errors.ScriptTimeoutError;
	import org.bytearray.gif.decoder.GIFDecoder;
	import org.bytearray.gif.events.GIFPlayerEvent;
	import org.bytearray.gif.events.FrameEvent;
	import org.bytearray.gif.events.TimeoutEvent;
	import org.bytearray.gif.events.FileTypeEvent;
	import org.bytearray.gif.errors.FileTypeError;
	import flash.display.Shape;

	public class GIFPlayer extends Shape
	{
		private var urlLoader:URLLoader;

		//timer
		private var myTimer:Timer;

		private var iInc:int;
		private var iIndex:int;
		private var auto:Boolean;
		private var arrayLng:uint;

		//datas
		private var aFrames:Array;
		private var aDelays:Array;
		private var aLoopCount:int = 0;

		//
		private var bitmapData:BitmapData = null;

		public function GIFPlayer(pAutoPlay:Boolean = true)
		{
			auto = pAutoPlay;
			iIndex = iInc = 0;

			myTimer = new Timer(1000/7, 0);
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

			myTimer.addEventListener(TimerEvent.TIMER, update);
		}

		private function onIOError(pEvt:IOErrorEvent):void
		{
			dispatchEvent(pEvt);
		}

		private function onComplete(pEvt:Event):void
		{
			readStream(pEvt.target.data);
		}

		private function readStream(pBytes:ByteArray):void
		{
			var gifStream:ByteArray = pBytes;

			aFrames = [];
			aDelays = [];
			iInc = 0;

			try
			{
				var gifDecoder:GIFDecoder = new GIFDecoder();
				gifDecoder.read(gifStream, false);
				aLoopCount = gifDecoder.getLoopCount();
				arrayLng = gifDecoder.getFrameCount();

				var clone:BitmapData = null;

				for (var i:int = 0; i < arrayLng; i++)
				{
					if (clone == null)
					{
						clone = gifDecoder.getFrame(0).clone();
					}
					if (gifDecoder.disposeValue == 2)
					{
						clone.fillRect(clone.rect, 0);
					}
					clone.draw(gifDecoder.getFrame(i));
					aFrames[i] = clone.clone();
					aDelays[i] = gifDecoder.getDelay(i);
				}
				
				clone.dispose();
				auto ? play():gotoAndStop(1);
				dispatchEvent(new GIFPlayerEvent(GIFPlayerEvent.COMPLETE, aFrames[0].rect));

			}
			catch (e:ScriptTimeoutError)
			{
				dispatchEvent(new TimeoutEvent(TimeoutEvent.TIME_OUT));

			}
			catch (e:FileTypeError)
			{
				dispatchEvent(new FileTypeEvent(FileTypeEvent.INVALID));

			}
			catch (e:Error)
			{
				throw new Error(("An unknown error occured, make sure the GIF file contains at least one frame\nNumber of frames : " + aFrames.length));
			}

		}

		private function update(pEvt:TimerEvent):void
		{
			iIndex = iInc++ % arrayLng;
			var delay:int = aDelays[iIndex];
			myTimer.delay = (delay > 0) ? delay:100;

			renderFrame(iIndex);
		}
		
		private function renderFrame(index:int):void{
			bitmapData = aFrames[iIndex];
			if (bitmapData)
			{
				this.graphics.clear();
				this.graphics.beginBitmapFill(bitmapData);
				this.graphics.drawRect(0,0,bitmapData.width,bitmapData.height);
				this.graphics.endFill();
				
				dispatchEvent(new FrameEvent(FrameEvent.FRAME_RENDERED, aFrames[iIndex]));
			}
		}

		/**
		 * Load any GIF file
		 *
		 * @return void
		 */
		public function load(pRequest:URLRequest):void
		{
			stop();
			urlLoader.load(pRequest);
		}

		/**
		 * Load any valid GIF ByteArray
		 *
		 * @return void
		 */
		public function loadBytes(pBytes:ByteArray):void
		{
			readStream(pBytes);
		}

		/**
		 * Start playing
		 *
		 * @return void
		 */
		public function play():void
		{
			if (aFrames.length > 0)
			{
				if (! myTimer.running)
				{
					myTimer.start();
				}
				renderFrame(iIndex);
			}
			else
			{
				throw new Error("Nothing to play");
			}
		}
		/**
		 * Stop playing
		 *
		 * @return void
		 */

		public function stop():void
		{
			if (myTimer.running)
			{
				myTimer.stop();
			}
		}

		/**
		 * Returns current frame being played
		 *
		 * @return frame number
		 */
		public function get currentFrame():int
		{
			return iIndex + 1;
		}

		/**
		 * Returns GIF's total frames
		 *
		 * @return number of frames
		 */
		public function get totalFrames():int
		{
			return arrayLng;
		}

		/**
		 * Returns how many times the GIF file is played
		 * A loop value of 0 means repeat indefinitiely.
		 *
		 * @return loop value
		 */
		public function get loopCount():int
		{
			return aLoopCount;
		}

		/**
		 * Returns is the autoPlay value
		 *
		 * @return autoPlay value
		 */
		public function get autoPlay():Boolean
		{
			return auto;
		}

		/**
		 * Returns an array of GIFFrame objects
		 *
		 * @return aFrames
		 */
		public function get frames():Array
		{
			return aFrames;
		}

		/**
		 * Moves the playhead to the specified frame and stops playing
		 *
		 * @return void
		 */
		public function gotoAndStop(pFrame:int):void
		{
			if (pFrame >= 1 && pFrame <= aFrames.length)
			{
				if (pFrame == currentFrame)
				{
					return;
				}
				iIndex = iInc = int(int(pFrame) - 1);

				renderFrame(iInc);

				if (myTimer.running)
				{
					myTimer.stop();
				}

			}
			else
			{
				throw new RangeError(("Frame out of range, please specify a frame between 1 and " + aFrames.length));
			}
		}/**
		 * Starts playing the GIF at the frame specified as parameter
		 *
		 * @return void
		 */

		public function gotoAndPlay(pFrame:int):void
		{
			if (pFrame >= 1 && pFrame <= aFrames.length)
			{
				if (pFrame == currentFrame)
				{
					return;
				}
				iIndex = iInc = int(int(pFrame) - 1);

				renderFrame(iInc);

				if (! myTimer.running)
				{
					myTimer.start();
				}
			}
			else
			{
				throw new RangeError(("Frame out of range, please specify a frame between 1 and " + aFrames.length));
			}
		}/**
		 * Retrieves a frame from the GIF file as a BitmapData
		 *
		 * @return BitmapData object
		 */

		public function getFrame(pFrame:int):BitmapData
		{
			var frame:BitmapData;

			if (pFrame >= 1 && pFrame <= aFrames.length)
			{
				frame = aFrames[pFrame - 1];

			}
			else
			{
				throw new RangeError(("Frame out of range, please specify a frame between 1 and " + aFrames.length));

			}
			return frame;
		}

		/**
		 * Retrieves the delay for a specific frame
		 *
		 * @return int
		 */
		public function getDelay(pFrame:int):int
		{
			var delay:int;

			if (pFrame >= 1 && pFrame <= aFrames.length)
			{
				delay = aDelays[pFrame - 1];

			}
			else
			{
				throw new RangeError(("Frame out of range, please specify a frame between 1 and " + aFrames.length));

			}
			return delay;
		}

		/**
		 * Dispose a GIFPlayer instance
		 *
		 * @return int
		 */
		public function dispose():void
		{
			stop();
			var lng:int = aFrames.length;

			for (var i:int = 0; i < lng; i++)
			{
				aFrames[int(i)].dispose();
			}
		}
	}
}